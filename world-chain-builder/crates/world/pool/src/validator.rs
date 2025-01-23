//! World Chain transaction pool types
use super::ordering::WorldChainOrdering;
use super::root::WorldChainRootValidator;
use super::tx::{WorldChainPoolTransaction, WorldChainPooledTransaction};
use crate::bindings::IPBHEntryPoint;
use crate::tx::WorldChainPoolTransactionError;
use alloy_primitives::Address;
use alloy_rlp::Decodable;
use alloy_sol_types::{SolCall, SolValue};
use rayon::iter::{IndexedParallelIterator, IntoParallelRefIterator, ParallelIterator};
use reth::core::primitives::{BlockBody, BlockHeader};
use reth::transaction_pool::{
    Pool, TransactionOrigin, TransactionValidationOutcome, TransactionValidationTaskExecutor,
    TransactionValidator,
};
use reth_optimism_node::txpool::OpTransactionValidator;
use reth_optimism_primitives::OpTransactionSigned;
use reth_primitives::{Block, SealedBlock};
use reth_provider::{BlockReaderIdExt, StateProviderFactory};
use semaphore::hash_to_field;
use world_chain_builder_pbh::payload::PbhPayload;

/// Type alias for World Chain transaction pool
pub type WorldChainTransactionPool<Client, S> = Pool<
    TransactionValidationTaskExecutor<
        WorldChainTransactionValidator<Client, WorldChainPooledTransaction>,
    >,
    WorldChainOrdering<WorldChainPooledTransaction>,
    S,
>;

/// Validator for World Chain transactions.
#[derive(Debug, Clone)]
pub struct WorldChainTransactionValidator<Client, Tx>
where
    Client: StateProviderFactory + BlockReaderIdExt,
{
    inner: OpTransactionValidator<Client, Tx>,
    root_validator: WorldChainRootValidator<Client>,
    num_pbh_txs: u8,
    pbh_validator: Address,
    pbh_signature_aggregator: Address,
}

impl<Client, Tx> WorldChainTransactionValidator<Client, Tx>
where
    Client: StateProviderFactory
        + BlockReaderIdExt<Block = reth_primitives::Block<OpTransactionSigned>>,
    Tx: WorldChainPoolTransaction<Consensus = OpTransactionSigned>,
{
    /// Create a new [`WorldChainTransactionValidator`].
    pub fn new(
        inner: OpTransactionValidator<Client, Tx>,
        root_validator: WorldChainRootValidator<Client>,
        num_pbh_txs: u8,
        pbh_validator: Address,
        pbh_signature_aggregator: Address,
    ) -> Self {
        Self {
            inner,
            root_validator,
            num_pbh_txs,
            pbh_validator,
            pbh_signature_aggregator,
        }
    }

    /// Get a reference to the inner transaction validator.
    pub fn inner(&self) -> &OpTransactionValidator<Client, Tx> {
        &self.inner
    }

    /// Validates a PBH bundle transaction
    ///
    /// If the transaction is valid marks it for priority inclusion
    pub fn validate_pbh_bundle(
        &self,
        origin: TransactionOrigin,
        mut tx: Tx,
    ) -> TransactionValidationOutcome<Tx> {
        // Ensure that the tx is a valid OP transaction
        let tx_outcome = self.inner.validate_one(origin, tx.clone());

        // Decode the calldata and check that all UserOp specify the PBH signature aggregator
        let Ok(calldata) = IPBHEntryPoint::handleAggregatedOpsCall::abi_decode(tx.input(), true)
        else {
            return WorldChainPoolTransactionError::InvalidCalldata.to_outcome(tx);
        };

        if !calldata
            ._0
            .iter()
            .all(|aggregator| aggregator.aggregator == self.pbh_signature_aggregator)
        {
            return WorldChainPoolTransactionError::InvalidSignatureAggregator.to_outcome(tx);
        }

        // Validate all proofs associated with each UserOp
        for aggregated_ops in calldata._0 {
            let mut buff = aggregated_ops.signature.as_ref();
            let pbh_payloads = match <Vec<PbhPayload>>::decode(&mut buff) {
                Ok(pbh_payloads) => pbh_payloads,
                Err(_) => return WorldChainPoolTransactionError::InvalidCalldata.to_outcome(tx),
            };

            if pbh_payloads.len() != aggregated_ops.userOps.len() {
                return WorldChainPoolTransactionError::MissingPbhPayload.to_outcome(tx);
            }

            let valid_roots = self.root_validator.roots();
            if let Err(err) = pbh_payloads
                .par_iter()
                .zip(aggregated_ops.userOps)
                .try_for_each(|(payload, op)| {
                    let signal = crate::eip4337::hash_user_op(&op);

                    payload.validate(signal, &valid_roots, self.num_pbh_txs)?;

                    Ok::<(), WorldChainPoolTransactionError>(())
                })
            {
                return err.to_outcome(tx);
            }
        }

        tx.set_valid_pbh();

        tx_outcome
    }

    /// Validates a PBH multicall transaction
    ///
    /// If the transaction is valid marks it for priority inclusion
    pub fn validate_pbh_multicall(
        &self,
        origin: TransactionOrigin,
        mut tx: Tx,
    ) -> TransactionValidationOutcome<Tx> {
        // Ensure that the tx is a valid OP transaction
        let tx_outcome = self.inner.validate_one(origin, tx.clone());

        // Decode the calldata and extract the PBH payload
        let Ok(calldata) = IPBHEntryPoint::pbhMulticallCall::abi_decode(tx.input(), true) else {
            return WorldChainPoolTransactionError::InvalidCalldata.to_outcome(tx);
        };

        let pbh_payload: PbhPayload = calldata.payload.into();
        let signal_hash: alloy_primitives::Uint<256, 4> =
            hash_to_field(&SolValue::abi_encode_packed(&(tx.sender(), calldata.calls)));

        // Verify the proof
        if let Err(err) =
            pbh_payload.validate(signal_hash, &self.root_validator.roots(), self.num_pbh_txs)
        {
            return WorldChainPoolTransactionError::PbhValidationError(err).to_outcome(tx);
        }

        tx.set_valid_pbh();

        tx_outcome
    }
}

impl<Client, Tx> TransactionValidator for WorldChainTransactionValidator<Client, Tx>
where
    Client: StateProviderFactory + BlockReaderIdExt<Block = Block<OpTransactionSigned>>,
    Tx: WorldChainPoolTransaction<Consensus = OpTransactionSigned>,
{
    type Transaction = Tx;

    async fn validate_transaction(
        &self,
        origin: TransactionOrigin,
        transaction: Self::Transaction,
    ) -> TransactionValidationOutcome<Self::Transaction> {
        if transaction.to().unwrap_or_default() != self.pbh_validator {
            return self.inner.validate_one(origin, transaction.clone());
        }

        let function_signature: [u8; 4] = transaction
            .input()
            .get(..4)
            .and_then(|bytes| bytes.try_into().ok())
            .unwrap_or_default();

        match function_signature {
            IPBHEntryPoint::handleAggregatedOpsCall::SELECTOR => {
                self.validate_pbh_bundle(origin, transaction)
            }
            IPBHEntryPoint::pbhMulticallCall::SELECTOR => {
                self.validate_pbh_multicall(origin, transaction)
            }
            _ => {
                WorldChainPoolTransactionError::InvalidCalldata.to_outcome(transaction)
            }
        }
    }

    fn on_new_head_block<H, B>(&self, new_tip_block: &SealedBlock<H, B>)
    where
        H: BlockHeader,
        B: BlockBody,
    {
        self.inner.on_new_head_block(new_tip_block);
        self.root_validator.on_new_block(new_tip_block);
    }
}

#[cfg(test)]
pub mod tests {
    use alloy_consensus::Header;
    use alloy_primitives::Address;
    use alloy_sol_types::SolCall;
    use ethers_core::rand::rngs::SmallRng;
    use ethers_core::rand::{Rng, SeedableRng};
    use reth::transaction_pool::blobstore::InMemoryBlobStore;
    use reth::transaction_pool::{Pool, TransactionPool, TransactionValidator};
    use reth_optimism_primitives::OpTransactionSigned;
    use reth_primitives::{BlockBody, SealedBlock, SealedHeader};
    use world_chain_builder_pbh::date_marker::DateMarker;
    use world_chain_builder_pbh::external_nullifier::ExternalNullifier;

    use super::WorldChainTransactionValidator;
    use crate::mock::{ExtendedAccount, MockEthProvider};
    use crate::ordering::WorldChainOrdering;
    use crate::root::LATEST_ROOT_SLOT;
    use crate::test_utils::{self, world_chain_validator, PBH_TEST_ENTRYPOINT, TEST_WORLD_ID};
    use crate::tx::WorldChainPooledTransaction;

    async fn setup() -> Pool<
        WorldChainTransactionValidator<MockEthProvider, WorldChainPooledTransaction>,
        WorldChainOrdering<WorldChainPooledTransaction>,
        InMemoryBlobStore,
    > {
        let validator = world_chain_validator();

        // Fund 10 test accounts
        for acc in 0..10 {
            let account_address = test_utils::account(acc);

            validator.inner.client().add_account(
                account_address,
                ExtendedAccount::new(0, alloy_primitives::U256::MAX),
            );
        }

        // Prep a merkle tree with first 5 accounts
        let tree = test_utils::tree();
        let root = tree.root();

        // Insert a world id root into the OpWorldId Account
        validator.inner.client().add_account(
            TEST_WORLD_ID,
            ExtendedAccount::new(0, alloy_primitives::U256::ZERO)
                .extend_storage(vec![(LATEST_ROOT_SLOT.into(), root)]),
        );
        let header = Header {
            gas_limit: 20000000,
            ..Default::default()
        };
        let sealed_header = SealedHeader::new(header.clone(), header.hash_slow());
        let body = BlockBody::<OpTransactionSigned>::default();
        let block = SealedBlock::new(sealed_header, body);

        // Propogate the block to the root validator
        validator.on_new_head_block(&block);

        let ordering = WorldChainOrdering::default();

        

        Pool::new(
            validator,
            ordering,
            InMemoryBlobStore::default(),
            Default::default(),
        )
    }

    #[tokio::test]
    async fn validate_noop_non_pbh() {
        const ACC: u32 = 0;

        let pool = setup().await;

        let account = test_utils::account(ACC);
        let tx = test_utils::eip1559().to(account).call();
        let tx = test_utils::eth_tx(ACC, tx).await;

        pool.add_external_transaction(tx.clone().into())
            .await
            .expect("Failed to add transaction");
    }

    #[tokio::test]
    async fn validate_no_duplicates() {
        const ACC: u32 = 0;

        let pool = setup().await;

        let account = test_utils::account(ACC);
        let tx = test_utils::eip1559().to(account).call();
        let tx = test_utils::eth_tx(ACC, tx).await;

        pool.add_external_transaction(tx.clone().into())
            .await
            .expect("Failed to add transaction");

        let res = pool.add_external_transaction(tx.clone().into()).await;

        assert!(res.is_err());
    }

    #[tokio::test]
    async fn validate_pbh_bundle() {
        const BUNDLER_ACCOUNT: u32 = 9;
        const USER_ACCOUNT: u32 = 0;

        let pool = setup().await;

        let (user_op, proof) = test_utils::user_op()
            .acc(USER_ACCOUNT)
            .external_nullifier(ExternalNullifier::with_date_marker(
                DateMarker::from(chrono::Utc::now()),
                0,
            ))
            .call();
        let bundle = test_utils::pbh_bundle(vec![user_op], vec![proof]);
        let calldata = bundle.abi_encode();

        let tx = test_utils::eip1559()
            .to(PBH_TEST_ENTRYPOINT)
            .input(calldata)
            .call();

        let tx = test_utils::eth_tx(BUNDLER_ACCOUNT, tx).await;

        pool.add_external_transaction(tx.clone().into())
            .await
            .expect("Failed to add transaction");
    }

    #[tokio::test]
    async fn validate_bundle_no_pbh() {
        let mut rng = SmallRng::seed_from_u64(42);

        const USER_ACCOUNT: u32 = 0;

        let pool = setup().await;

        // NOTE: We're ignoring the proof here
        let (user_op, _proof) = test_utils::user_op()
            .acc(USER_ACCOUNT)
            .external_nullifier(ExternalNullifier::with_date_marker(
                DateMarker::from(chrono::Utc::now()),
                0,
            ))
            .call();

        let bundle = test_utils::pbh_bundle(vec![user_op], vec![]);

        let calldata = bundle.abi_encode();

        let tx = test_utils::eip1559()
            // NOTE: Random receiving account
            .to(rng.gen::<Address>())
            .input(calldata)
            .call();

        let tx = test_utils::eth_tx(USER_ACCOUNT, tx).await;

        pool.add_external_transaction(tx.clone().into())
            .await
            .expect(
                "Validation should succeed - PBH data is invalid, but this is not a PBH bundle",
            );
    }

    #[tokio::test]
    async fn validate_pbh_bundle_missing_proof_for_user_op() {
        const BUNDLER_ACCOUNT: u32 = 9;
        const USER_ACCOUNT: u32 = 0;

        let pool = setup().await;

        // NOTE: We're ignoring the proof here
        let (user_op, _proof) = test_utils::user_op()
            .acc(USER_ACCOUNT)
            .external_nullifier(ExternalNullifier::with_date_marker(
                DateMarker::from(chrono::Utc::now()),
                0,
            ))
            .call();

        let bundle = test_utils::pbh_bundle(vec![user_op], vec![]);

        let calldata = bundle.abi_encode();

        let tx = test_utils::eip1559()
            .to(PBH_TEST_ENTRYPOINT)
            .input(calldata)
            .call();

        let tx = test_utils::eth_tx(BUNDLER_ACCOUNT, tx).await;

        let err = pool
            .add_external_transaction(tx.clone().into())
            .await
            .expect_err("Validation should fail because of missing proof");

        assert!(err
            .to_string()
            .contains("one or more user ops are missing pbh payloads"),);
    }

    #[tokio::test]
    async fn validate_pbh_multicall() {
        const USER_ACCOUNT: u32 = 1;

        let pool = setup().await;

        let calldata = test_utils::pbh_multicall()
            .acc(USER_ACCOUNT)
            .external_nullifier(ExternalNullifier::with_date_marker(
                DateMarker::from(chrono::Utc::now()),
                0,
            ))
            .call();
        let calldata = calldata.abi_encode();

        let tx = test_utils::eip1559()
            .to(PBH_TEST_ENTRYPOINT)
            .input(calldata)
            .call();

        let tx = test_utils::eth_tx(USER_ACCOUNT, tx).await;

        pool.add_external_transaction(tx.clone().into())
            .await
            .expect("Failed to add PBH multicall transaction");
    }

    #[tokio::test]
    async fn validate_date_marker_outdated() {
        const BUNDLER_ACCOUNT: u32 = 9;
        const USER_ACCOUNT: u32 = 0;

        let pool = setup().await;

        let now = chrono::Utc::now();
        let month_in_the_past = now - chrono::Months::new(1);

        // NOTE: We're ignoring the proof here
        let (user_op, proof) = test_utils::user_op()
            .acc(USER_ACCOUNT)
            .external_nullifier(ExternalNullifier::with_date_marker(
                DateMarker::from(month_in_the_past),
                0,
            ))
            .call();

        let bundle = test_utils::pbh_bundle(vec![user_op], vec![proof]);

        let calldata = bundle.abi_encode();

        let tx = test_utils::eip1559()
            .to(PBH_TEST_ENTRYPOINT)
            .input(calldata)
            .call();

        let tx = test_utils::eth_tx(BUNDLER_ACCOUNT, tx).await;

        let err = pool
            .add_external_transaction(tx.clone().into())
            .await
            .expect_err("Validation should fail because of missing proof");

        assert!(err
            .to_string()
            .contains("invalid external nullifier period"),);
    }

    #[tokio::test]
    async fn validate_date_marker_in_the_future() {
        const BUNDLER_ACCOUNT: u32 = 9;
        const USER_ACCOUNT: u32 = 0;

        let pool = setup().await;

        let now = chrono::Utc::now();
        let month_in_the_future = now + chrono::Months::new(1);

        // NOTE: We're ignoring the proof here
        let (user_op, proof) = test_utils::user_op()
            .acc(USER_ACCOUNT)
            .external_nullifier(ExternalNullifier::with_date_marker(
                DateMarker::from(month_in_the_future),
                0,
            ))
            .call();

        let bundle = test_utils::pbh_bundle(vec![user_op], vec![proof]);

        let calldata = bundle.abi_encode();

        let tx = test_utils::eip1559()
            .to(PBH_TEST_ENTRYPOINT)
            .input(calldata)
            .call();

        let tx = test_utils::eth_tx(BUNDLER_ACCOUNT, tx).await;

        let err = pool
            .add_external_transaction(tx.clone().into())
            .await
            .expect_err("Validation should fail because of missing proof");

        assert!(err
            .to_string()
            .contains("invalid external nullifier period"),);
    }

    #[tokio::test]
    async fn invalid_external_nullifier_nonce() {
        const BUNDLER_ACCOUNT: u32 = 9;
        const USER_ACCOUNT: u32 = 0;

        let pool = setup().await;

        let (user_op, proof) = test_utils::user_op()
            .acc(USER_ACCOUNT)
            .external_nullifier(ExternalNullifier::with_date_marker(
                DateMarker::from(chrono::Utc::now()),
                255,
            ))
            .call();

        let bundle = test_utils::pbh_bundle(vec![user_op], vec![proof]);

        let calldata = bundle.abi_encode();

        let tx = test_utils::eip1559()
            .to(PBH_TEST_ENTRYPOINT)
            .input(calldata)
            .call();

        let tx = test_utils::eth_tx(BUNDLER_ACCOUNT, tx).await;

        let err = pool
            .add_external_transaction(tx.clone().into())
            .await
            .expect_err("Validation should fail because of missing proof");

        assert!(err.to_string().contains("invalid external nullifier nonce"),);
    }
}
