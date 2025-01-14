#include <Trade/Trade.mqh>

input double Lots = 0.1;
input double ClosePercent = 30;
input double SlFactor = 2;
input double TpFactor = 0.5;

input ENUM_TIMEFRAMES Timeframe = PERIOD_CURRENT;
input int Periods = 20;
input double Deviation = 2.0;
input ENUM_APPLIED_PRICE AppPrice = PRICE_CLOSE;

input bool IsMaFilter = true;
input ENUM_TIMEFRAMES MaTimeframe = PERIOD_CURRENT;
input int MaPeriods = 200;
input ENUM_MA_METHOD MaMethot = MODE_SMA;
input ENUM_APPLIED_PRICE MaAppPrice = PRICE_CLOSE;

int handleBb;
int handleMa;
int barsTotal;


CTrade trade;

int OnInit(){

 barsTotal = iBars(_Symbol,Timeframe);

 handleBb = iBands(_Symbol,Timeframe,Periods,0,Deviation,AppPrice);
 handleMa = iMA(_Symbol,MaTimeframe,MaPeriods,0,MaMethot,MaAppPrice);
  

 return(INIT_SUCCEEDED);
 }

void OnDeinit(const int reason){

  
 }

void OnTick(){
  int bars = iBars(_Symbol, Timeframe);
  if (barsTotal < bars){
    barsTotal = bars;

    double bbUpper[], bbLower[], bbMiddle[];
    CopyBuffer(handleBb, BASE_LINE, 1, 2, bbMiddle);
    CopyBuffer(handleBb, UPPER_BAND, 1, 2, bbUpper);
    CopyBuffer(handleBb, LOWER_BAND, 1, 2, bbLower);

    double ma[];
    CopyBuffer(handleMa, BASE_LINE, 1, 1, ma);

    double close1 = iClose(_Symbol, Timeframe, 1);
    double close2 = iClose(_Symbol, Timeframe, 2);

    double maDistance = MathAbs(ma[0] - close1);
    double distance = bbUpper[1] - bbLower[1];

    if (maDistance > 0.002347) {
      if (distance > 0.004047) {
        if (close1 > bbUpper[1] && close2 < bbUpper[0]) {
          Print("Close is above the bbUpper");

          double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
          bid = NormalizeDouble(bid, _Digits);

          if (!IsMaFilter || bid < ma[0]) {
            double sl = bid + distance * SlFactor;
            sl = NormalizeDouble(sl, _Digits);

            double tp = bid - distance * TpFactor / 2;
            tp = NormalizeDouble(tp, _Digits);

            trade.Sell(Lots, _Symbol, bid, sl, tp);
          }
        } else if (close1 < bbLower[1] && close2 > bbLower[0]) {
          Print("Close is below the bbLower");

          double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
          ask = NormalizeDouble(ask, _Digits);

          if (!IsMaFilter || ask > ma[0]) {
            double sl = ask - distance * SlFactor;
            sl = NormalizeDouble(sl, _Digits);

            double tp = ask + distance * TpFactor / 2;
            tp = NormalizeDouble(tp, _Digits);

            trade.Buy(Lots, _Symbol, ask, sl, tp);
          }
        } 
        if (close1 > bbLower[1] && close2 < bbLower[0]) {
          Print("Close is above the bbLower");

          double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
          ask = NormalizeDouble(ask, _Digits);

          if (!IsMaFilter || ask < ma[0]) {
            double sl = ask - distance * SlFactor;
            sl = NormalizeDouble(sl, _Digits);

            double tp = ask + distance * TpFactor /3;
            tp = NormalizeDouble(tp, _Digits);

            trade.Buy(Lots, _Symbol, ask, sl, tp);
          }
        } else if (close1 < bbUpper[1] && close2 > bbUpper[0]) {
          Print("Close is below the bbUpper");

          double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
          ask = NormalizeDouble(ask, _Digits);

          if (!IsMaFilter || ask > ma[0]) {
            double sl = ask - distance * SlFactor;
            sl = NormalizeDouble(sl, _Digits);

            double tp = ask + distance * TpFactor / 3;
            tp = NormalizeDouble(tp, _Digits);

            trade.Buy(Lots, _Symbol, ask, sl, tp);
          }
        }
         
        if (close1 > bbLower[1] && close2 < bbLower[0]) {
          Print("Close is above the bbLower");

          double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
          bid = NormalizeDouble(bid, _Digits);

          if (!IsMaFilter || bid < ma[0]) {
            double sl = bid + distance * SlFactor;
            sl = NormalizeDouble(sl, _Digits);

            double tp = bid - distance * TpFactor / 3;
            tp = NormalizeDouble(tp, _Digits);

            trade.Sell(Lots, _Symbol, bid, sl, tp);
          }
        }
        
      }else {
        Print("Mesafe çok kısa");
      }
    } else {
      Print("Hareketli ortalama ile fiyat arasındaki mesafe çok yakın. İşlem yapılmayacak.");
    }

    string comment;
    comment = "BB Middle[0]: " + DoubleToString(bbMiddle[0], _Digits) + "| BB Middle[1]: " + DoubleToString(bbMiddle[1], _Digits);
    comment += "\nBB Upper[0]: " + DoubleToString(bbUpper[0], _Digits) + "| BB Upper[1]: " + DoubleToString(bbUpper[1], _Digits);
    comment += "\nBB Lower[0]: " + DoubleToString(bbLower[0], _Digits) + "| BB Lower[1]: " + DoubleToString(bbLower[1], _Digits);
    comment += "\nMA [0]: " + DoubleToString(ma[0], _Digits);
    comment += "\nClose: " + DoubleToString(close1, _Digits) + " | Close2:" + DoubleToString(close2, _Digits);
    Comment(comment);
  }
}