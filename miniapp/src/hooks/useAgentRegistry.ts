import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { parseEther } from 'viem';
import { CONTRACTS } from '../contracts/addresses';
import { AgentRegistryABI } from '../contracts/abis';

export function useRegisterAgent() {
  const { writeContract, data: hash, isPending, error } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const registerAgent = async (name: string, metadataURI: string, stake: string) => {
    return writeContract({
      address: CONTRACTS.AgentRegistry,
      abi: AgentRegistryABI,
      functionName: 'registerAgent',
      args: [name, metadataURI],
      value: parseEther(stake),
    });
  };

  return {
    registerAgent,
    isPending: isPending || isConfirming,
    isSuccess,
    error,
    hash,
  };
}

export function useSponsorAgent() {
  const { writeContract, data: hash, isPending, error } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const sponsorAgent = async (agentId: number, amount: string) => {
    return writeContract({
      address: CONTRACTS.AgentRegistry,
      abi: AgentRegistryABI,
      functionName: 'sponsorAgent',
      args: [BigInt(agentId)],
      value: parseEther(amount),
    });
  };

  return {
    sponsorAgent,
    isPending: isPending || isConfirming,
    isSuccess,
    error,
    hash,
  };
}

export function useAgent(agentId: number | undefined) {
  const { data, isLoading, error } = useReadContract({
    address: CONTRACTS.AgentRegistry,
    abi: AgentRegistryABI,
    functionName: 'getAgent',
    args: agentId !== undefined ? [BigInt(agentId)] : undefined,
    query: {
      enabled: agentId !== undefined,
    },
  });

  return {
    agent: data,
    isLoading,
    error,
  };
}

export function useTotalAgents() {
  const { data, isLoading, error } = useReadContract({
    address: CONTRACTS.AgentRegistry,
    abi: AgentRegistryABI,
    functionName: 'totalAgents',
  });

  return {
    totalAgents: data ? Number(data) : 0,
    isLoading,
    error,
  };
}
