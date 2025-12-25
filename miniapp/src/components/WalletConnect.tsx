import { useAccount, useConnect, useDisconnect } from 'wagmi';

export function WalletConnect() {
  const { address, isConnected } = useAccount();
  const { connect, connectors, isPending } = useConnect();
  const { disconnect } = useDisconnect();

  if (isConnected && address) {
    return (
      <div className="wallet-connected">
        <div className="wallet-info">
          <span className="wallet-address">
            {address.slice(0, 6)}...{address.slice(-4)}
          </span>
        </div>
        <button onClick={() => disconnect()} className="btn-disconnect">
          Disconnect
        </button>
      </div>
    );
  }

  return (
    <div className="wallet-connect">
      {connectors.map((connector) => (
        <button
          key={connector.id}
          onClick={() => connect({ connector })}
          disabled={isPending}
          className="btn-connect"
        >
          {isPending ? 'Connecting...' : `Connect ${connector.name}`}
        </button>
      ))}
    </div>
  );
}
