#!/bin/bash

echo "أدخل BIN (مثلاً: 453968 أو 527484):"
read BIN

if ! [[ $BIN =~ ^[0-9]{6}$ ]]; then
    echo "BIN غير صالح! خاصو يكون 6 أرقام."
    exit 1
fi

echo "كم بطاقة تريد توليدها؟"
read NUM

if ! [[ $NUM =~ ^[0-9]+$ ]]; then
    echo "رقم غير صالح!"
    exit 1
fi

for ((i=1; i<=$NUM; i++)); do
  RND=$(shuf -i 100000000-999999999 -n 1)
  CARD="$BIN$RND"

  LUHN=$(python3 -c "
def luhn_checksum(card_number):
    def digits_of(n): return [int(d) for d in str(n)]
    digits = digits_of(card_number)
    odd = digits[-1::-2]
    even = digits[-2::-2]
    total = sum(odd)
    for d in even:
        total += sum(digits_of(d*2))
    return (10 - (total % 10)) % 10
print(luhn_checksum('$CARD'))
")
  FULL="$CARD$LUHN"
  EXP=$(date -d "+$((RANDOM % 24 + 1)) months" +"%m/%y")
  CVV=$(shuf -i 100-999 -n 1)

  echo "-----------------------------"
  echo "بطاقة رقم $i:"
  echo "الرقم     : $FULL"
  echo "الاسم     : TEST USER"
  echo "الانتهاء : $EXP"
  echo "CVV       : $CVV"
done
