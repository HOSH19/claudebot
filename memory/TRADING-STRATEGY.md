# Trading Strategy

## Mission

Beat the S&P 500 over the challenge window. Stocks only — no options, ever.

## Capital & Constraints

- Starting capital: ~$10,000
- Platform: Alpaca
- Instruments: Stocks ONLY
- PDT limit: 3 day trades per 5 rolling days (account < $25k)

## Core Rules

1. NO OPTIONS — ever
2. 75-85% deployed
3. 5-6 positions at a time, max 20% each
4. 10% trailing stop on every position as a real GTC order
5. Cut losers at -7% manually
6. Tighten trail: 7% at +15%, 5% at +20%
7. Never within 3% of current price; never move a stop down
8. Max 3 new trades per week
9. Follow sector momentum
10. Exit a sector after 2 consecutive failed trades
11. Patience > activity

## Entry Checklist

- Specific catalyst?
- Sector in momentum?
- Stop level (7-10% below entry)
- Target (min 2:1 R:R)

## Buy-Side Gate (every check must pass before placing a buy)

- Total positions after this fill ≤ 6
- Total trades placed this week (including this one) ≤ 3
- Position cost ≤ 20% of account equity
- Position cost ≤ available cash
- `daytrade_count` leaves room (under 3 on a sub-$25k account)
- A specific catalyst is documented in today's RESEARCH-LOG entry
- Instrument is a stock (not an option, not anything else)

## Sell-Side Rules

- Unrealized P&L ≤ -7% → close immediately, cancel trailing stop, log exit
- Thesis broken (catalyst invalidated, sector rolling over, news event) → close even if not yet at -7%
- Up ≥ +20% → tighten trailing stop to 5%
- Up ≥ +15% → tighten trailing stop to 7%
- Sector with 2 consecutive failed trades → exit all positions in that sector
