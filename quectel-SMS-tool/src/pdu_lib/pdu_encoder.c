#include "pdu.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <wchar.h>
#include <locale.h>

static const char base64_alphabet[] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G',
    'H', 'I', 'J', 'K', 'L', 'M', 'N',
    'O', 'P', 'Q', 'R', 'S', 'T',
    'U', 'V', 'W', 'X', 'Y', 'Z',
    'a', 'b', 'c', 'd', 'e', 'f', 'g',
    'h', 'i', 'j', 'k', 'l', 'm', 'n',
    'o', 'p', 'q', 'r', 's', 't',
    'u', 'v', 'w', 'x', 'y', 'z',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    '+', '/'};

static const unsigned char base64_suffix_map[256] = {
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 253, 255,
    255, 253, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 253, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255,  62, 255, 255, 255,  63,
    52,  53,  54,  55,  56,  57,  58,  59,  60,  61, 255, 255,
    255, 254, 255, 255, 255,   0,   1,   2,   3,   4,   5,   6,
    7,   8,   9,  10,  11,  12,  13,  14,  15,  16,  17,  18,
    19,  20,  21,  22,  23,  24,  25, 255, 255, 255, 255, 255,
    255,  26,  27,  28,  29,  30,  31,  32,  33,  34,  35,  36,
    37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,  48,
    49,  50,  51, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255 };

int base64_decode(const char *indata, unsigned char *outdata, int *outlen) {
    int ret = 0;
    int inlen = strlen(indata);
    if (indata == NULL || inlen <= 0 || outdata == NULL || outlen == NULL) {
        return ret = -1;
    }

    if (inlen % 4 != 0) { // 需要解码的数据不是4字节倍数
        return ret = -2;
    }

    int t = 0, x = 0, y = 0, i = 0;
    unsigned char c = 0;
    int g = 3;

    while (indata[x] != 0) {
        // 需要解码的数据对应的ASCII值对应base64_suffix_map的值
        c = base64_suffix_map[indata[x++]];
        if (c == 255) return -1;// 对应的值不在转码表中
        if (c == 253) continue;// 对应的值是换行或者回车
        if (c == 254) { c = 0; g--; }// 对应的值是'='
        t = (t<<6) | c; // 将其依次放入一个int型中占3字节
        if (++y == 4) {
            outdata[i++] = (unsigned char)((t>>16)&0xff);
            if (g > 1) outdata[i++] = (unsigned char)((t>>8)&0xff);
            if (g > 2) outdata[i++] = (unsigned char)(t&0xff);
            y = t = 0;
        }
    }
    if (outlen != NULL) {
        *outlen = i;
    }
    return ret;
}

#define isunicode(c) (((c)&0xc0)==0xc0)

int utf8_decode(const char *str, int *i) {
    const unsigned char *s = (const unsigned char *)str;
    int u = *s, l = 1;
    if(isunicode(u)) {
        int a = (u&0x20)? ((u&0x10)? ((u&0x08)? ((u&0x04)? 6 : 5) : 4) : 3) : 2;
        if(a<6 || !(u&0x02)) {
            int b,p = 0;
            u = ((u<<(a+1))&0xff)>>(a+1);
            for(b=1; b<a; ++b)
                u = (u<<6)|(s[l++]&0x3f);
        }
    }
    if(i) *i = l;
    return u;
}

int sms_encode(char* argv[]) {
    unsigned char* str3 = (unsigned char *)malloc( MB_CUR_MAX );
    int len = 0;
    base64_decode(argv[1], str3, &len);
    //printf("string -> Length:%d %s \n", len, str3);

    wchar_t *chinese_str = (wchar_t *)malloc( len * sizeof(wchar_t) );

    int l, idx = 0;
    for (int i = 0; i < len; i++, idx++) {
        if(!isunicode(str3[i])) {
            chinese_str[idx] = str3[i];
        } else {
            chinese_str[idx] = utf8_decode(&str3[i], &l);
            i += l-1;
        }
    }





    unsigned char pdu[SMS_MAX_PDU_LENGTH];
    char pdustr[2*SMS_MAX_PDU_LENGTH+4];
    int pdu_len = pdu_encode("", "8618612648390", chinese_str, pdu, sizeof(pdu));
    const int pdu_len_except_smsc = pdu_len - 1 - pdu[0];

    int i;
    for (i = 0; i < pdu_len; ++i)
        sprintf(pdustr+2*i, "%02X", pdu[i]);
    sprintf(pdustr+2*i, "%c\r\n", 0x1A);   // End PDU mode with Ctrl-Z.

	printf("send -> Length:%d PDU: %s \n", pdu_len_except_smsc, pdustr);
	return 0;
}

int main(int argc, char* argv[]) {
    setlocale(LC_ALL,"");
	return sms_encode(argv);
}

