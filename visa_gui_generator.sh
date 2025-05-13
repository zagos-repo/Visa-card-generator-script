#!/bin/bash

# التحقق من وجود Zenity
if ! command -v zenity &> /dev/null; then
    echo "البرنامج zenity غير مثبت. يرجى تثبيته بالأمر: sudo apt install zenity"
    exit 1
fi

# إدخال BIN عبر نافذة Zenity
BIN=$(zenity --entry --title="توليد بطاقة VISA" --text="أدخل BIN مكوّن من 6 أرقام (مثلاً: 453968):")

if ! [[ $BIN =~ ^[0-9]{6}$ ]]; then
    zenity --error --text="BIN غير صالح! يجب أن يتكون من 6 أرقام."
    exit 1
fi

# عدد البطاقات
NUM=$(zenity --entry --title="عدد البطاقات" --text="كم بطاقة تريد توليدها؟")

if ! [[ $NUM =~ ^[0-9]+$ ]]; then
    zenity --error --text="رقم غير صالح!"
    exit 1
fi

# ملف مؤقت للتخزين
OUTFILE=$(mktemp)

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

  echo "بطاقة رقم $i:" >> "$OUTFILE"
  echo "الرقم     : $FULL" >> "$OUTFILE"
  echo "الانتهاء : $EXP" >> "$OUTFILE"
  echo "CVV       : $CVV" >> "$OUTFILE"
  echo "----------------------" >> "$OUTFILE"
done

zenity --text-info --filename="$OUTFILE" --title="البطاقات المُولدة" --width=500 --height=400
