# Trading Strategy

## Mission

Beat the S&P 500 over the challenge window. Stocks only — no options, ever.

## Universe (fixed — 20 symbols)

Tech: AAPL, MSFT, GOOGL, AMZN, NVDA, META, TSLA, AMD, AVGO, TSM
Finance: JPM, GS, V, MA
Energy: XOM, CVX
Healthcare: UNH, JNJ
ETFs: SPY, QQQ

Only trade symbols from this list. No exceptions.

## Capital & Constraints

- Starting capital: ~$100,000 (paper account)
- Platform: Alpaca
- Instruments: Stocks ONLY (universe above)
- PDT limit: 3 day trades per 5 rolling days (account < $25k)

## Core Rules

1. NO OPTIONS — ever
2. 80% deployed (target)
3. Up to 10 positions, max 8% each
4. 10% trailing stop on every position as a real GTC order
5. Cut losers at -7% manually
6. Tighten trail: 7% at +15%, 5% at +20%
7. Never within 3% of current price; never move a stop down
8. Max 3 new trades per week
9. Follow sector momentum
10. Exit a sector after 2 consecutive failed trades
11. Portfolio DD halt: if equity drops 10% from session-start equity, stop all new buys for the day
12. Patience > activity

## Candidate Scoring (min 7/10 to advance to trade idea)

Score each candidate before including it in RESEARCH-LOG. Only ≥7 candidates may become trade ideas.

| # | Factor | 0 | 1 | 2 |
|---|--------|---|---|---|
| 1 | Catalyst strength | Vague rumor | Scheduled event | Confirmed catalyst |
| 2 | Sector rank YTD | Bottom third | Mid third | Top third |
| 3 | Technical setup (vs 20d SMA) | >10% extended | 5–10% above | At or below |
| 4 | Volume confirmation | Below avg | 1–1.5× avg | >1.5× avg |
| 5 | R:R ratio | <1.5 | 1.5–2.0 | >2.0 |

Log format in RESEARCH-LOG per candidate:
`TICKER | Score: X/10 | Catalyst: N | Sector: N | Setup: N | Volume: N | R:R: N`

## Entry Checklist

- Candidate scored ≥ 7/10 (required)
- Specific catalyst?
- Sector in momentum?
- Stop level (7-10% below entry)
- Target (min 2:1 R:R)

## Buy-Side Gate (every check must pass before placing a buy)

- Total positions after this fill ≤ 10
- Total trades placed this week (including this one) ≤ 3
- Position cost ≤ 8% of account equity
- Position cost ≤ available cash
- Symbol is in the 20-symbol universe
- Portfolio equity has not dropped 10%+ from today's session-start equity
- `daytrade_count` leaves room (under 3 on a sub-$25k account)
- A specific catalyst is documented in today's RESEARCH-LOG entry
- Instrument is a stock (not an option, not anything else)

## Sell-Side Rules

- Unrealized P&L ≤ -7% → close immediately, cancel trailing stop, log exit
- Thesis broken (catalyst invalidated, sector rolling over, news event) → close even if not yet at -7%
- Up ≥ +20% → tighten trailing stop to 5%
- Up ≥ +15% → tighten trailing stop to 7%
- Sector with 2 consecutive failed trades → exit all positions in that sector
