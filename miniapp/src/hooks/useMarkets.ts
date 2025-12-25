import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { parseEther } from 'viem';
import { CONTRACTS } from '../contracts/addresses';
import { MarketFactoryABI, BettingEngineABI } from '../contracts/abis';

export function useCreateMarket() {
  const { writeContract, data: hash, isPending, error } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const createMarket = async (
    agentId: number,
    question: string,
    description: string,
    category: number,
    outcomes: string[],
    durationDays: number
  ) => {
    const durationSeconds = BigInt(durationDays * 24 * 60 * 60);

    return writeContract({
      address: CONTRACTS.MarketFactory,
      abi: MarketFactoryABI,
      functionName: 'createMarket',
      args: [BigInt(agentId), question, description, category, outcomes, durationSeconds],
    });
  };

  return {
    createMarket,
    isPending: isPending || isConfirming,
    isSuccess,
    error,
    hash,
  };
}

export function useMarket(marketId: number | undefined) {
  const { data, isLoading, error, refetch } = useReadContract({
    address: CONTRACTS.MarketFactory,
    abi: MarketFactoryABI,
    functionName: 'getMarket',
    args: marketId !== undefined ? [BigInt(marketId)] : undefined,
    query: {
      enabled: marketId !== undefined,
    },
  });

  return {
    market: data,
    isLoading,
    error,
    refetch,
  };
}

export function useTotalMarkets() {
  const { data, isLoading, error } = useReadContract({
    address: CONTRACTS.MarketFactory,
    abi: MarketFactoryABI,
    functionName: 'totalMarkets',
  });

  return {
    totalMarkets: data ? Number(data) : 0,
    isLoading,
    error,
  };
}

export function usePlaceBet() {
  const { writeContract, data: hash, isPending, error } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const placeBet = async (
    marketId: number,
    outcomeIndex: number,
    betAmount: string,
    minPayout: string = '0'
  ) => {
    return writeContract({
      address: CONTRACTS.BettingEngine,
      abi: BettingEngineABI,
      functionName: 'placeBet',
      args: [BigInt(marketId), BigInt(outcomeIndex), parseEther(minPayout)],
      value: parseEther(betAmount),
    });
  };

  return {
    placeBet,
    isPending: isPending || isConfirming,
    isSuccess,
    error,
    hash,
  };
}

export function useGetOdds(marketId: number, outcomeIndex: number, betAmount: string) {
  const { data, isLoading, error } = useReadContract({
    address: CONTRACTS.BettingEngine,
    abi: BettingEngineABI,
    functionName: 'getOdds',
    args: [BigInt(marketId), BigInt(outcomeIndex), parseEther(betAmount)],
    query: {
      enabled: betAmount !== '' && parseFloat(betAmount) > 0,
    },
  });

  return {
    odds: data,
    isLoading,
    error,
  };
}

export function useClaimWinnings() {
  const { writeContract, data: hash, isPending, error } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const claimWinnings = async (marketId: number) => {
    return writeContract({
      address: CONTRACTS.BettingEngine,
      abi: BettingEngineABI,
      functionName: 'claimWinnings',
      args: [BigInt(marketId)],
    });
  };

  return {
    claimWinnings,
    isPending: isPending || isConfirming,
    isSuccess,
    error,
    hash,
  };
}
