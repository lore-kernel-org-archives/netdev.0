From: "=?UTF-8?Q?Rui_Tiago_Ca=C3=A7=C3=A3o_Matos?=" <rmatos@av.it.pt>
Subject: [PATCH][LIBNL] Remove usage of C++ keyword 'class' on htb.h header
Date: Tue, 4 Mar 2008 15:30:12 +0000
Message-ID: <eae3b3410803040730s1b02be55m1bc0a717cc53ccd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_55950_10709858.1204644612812"
Cc: tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.228]:12056 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759304AbYCDPaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 10:30:16 -0500
Received: by wr-out-0506.google.com with SMTP id 50so1262896wra.13
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2008 07:30:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_55950_10709858.1204644612812
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline



------=_Part_55950_10709858.1204644612812
Content-Type: text/x-patch;
 name=0001-Remove-usage-of-C-keyword-class-on-htb.h-header.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fdem9s05
Content-Disposition: attachment;
 filename=0001-Remove-usage-of-C-keyword-class-on-htb.h-header.patch

RnJvbSAzNzkyNzAxMzM2NDA0MGZjNzUxMmYzZjc1NzMxYjZhMzg2NzQwOTQ4IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiA9P3V0Zi04P3E/UnVpPTIwVGlhZ289MjBDYT1DMz1BNz1DMz1B
M289MjBNYXRvcz89IDxybWF0b3NAYXYuaXQucHQ+CkRhdGU6IFR1ZSwgNCBNYXIgMjAwOCAxNTox
MzowNiArMDAwMApTdWJqZWN0OiBbUEFUQ0hdIFJlbW92ZSB1c2FnZSBvZiBDKysga2V5d29yZCAn
Y2xhc3MnIG9uIGh0Yi5oIGhlYWRlci4KTUlNRS1WZXJzaW9uOiAxLjAKQ29udGVudC1UeXBlOiB0
ZXh0L3BsYWluOyBjaGFyc2V0PXV0Zi04CkNvbnRlbnQtVHJhbnNmZXItRW5jb2Rpbmc6IDhiaXQK
ClNpZ25lZC1vZmYtYnk6IFJ1aSBUaWFnbyBDYcOnw6NvIE1hdG9zIDxybWF0b3NAYXYuaXQucHQ+
Ci0tLQogaW5jbHVkZS9uZXRsaW5rL3JvdXRlL3NjaC9odGIuaCB8ICAgIDYgKysrLS0tCiAxIGZp
bGVzIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwgMyBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQg
YS9pbmNsdWRlL25ldGxpbmsvcm91dGUvc2NoL2h0Yi5oIGIvaW5jbHVkZS9uZXRsaW5rL3JvdXRl
L3NjaC9odGIuaAppbmRleCA1ZDRkNjgxLi5kNDRmMDM5IDEwMDY0NAotLS0gYS9pbmNsdWRlL25l
dGxpbmsvcm91dGUvc2NoL2h0Yi5oCisrKyBiL2luY2x1ZGUvbmV0bGluay9yb3V0ZS9zY2gvaHRi
LmgKQEAgLTMwLDkgKzMwLDkgQEAgZXh0ZXJuIHZvaWQgcnRubF9odGJfc2V0X3JhdGUoc3RydWN0
IHJ0bmxfY2xhc3MgKiwgdWludDMyX3QpOwogZXh0ZXJuIHZvaWQgcnRubF9odGJfc2V0X2NlaWwo
c3RydWN0IHJ0bmxfY2xhc3MgKiwgdWludDMyX3QpOwogZXh0ZXJuIHZvaWQgcnRubF9odGJfc2V0
X3JidWZmZXIoc3RydWN0IHJ0bmxfY2xhc3MgKiwgdWludDMyX3QpOwogZXh0ZXJuIHZvaWQgcnRu
bF9odGJfc2V0X2NidWZmZXIoc3RydWN0IHJ0bmxfY2xhc3MgKiwgdWludDMyX3QpOwotZXh0ZXJu
IHZvaWQgcnRubF9odGJfc2V0X3F1YW50dW0oc3RydWN0IHJ0bmxfY2xhc3MgKmNsYXNzLCB1aW50
MzJfdCBxdWFudHVtKTsKLWV4dGVybiB2b2lkIHJ0bmxfaHRiX3NldF9vdmVyaGVhZChzdHJ1Y3Qg
cnRubF9jbGFzcyAqY2xhc3MsIHVpbnQ4X3Qgb3ZlcmhlYWQpOwotZXh0ZXJuIHZvaWQgcnRubF9o
dGJfc2V0X21wdShzdHJ1Y3QgcnRubF9jbGFzcyAqY2xhc3MsIHVpbnQ4X3QgbXB1KTsKK2V4dGVy
biB2b2lkIHJ0bmxfaHRiX3NldF9xdWFudHVtKHN0cnVjdCBydG5sX2NsYXNzICosIHVpbnQzMl90
IHF1YW50dW0pOworZXh0ZXJuIHZvaWQgcnRubF9odGJfc2V0X292ZXJoZWFkKHN0cnVjdCBydG5s
X2NsYXNzICosIHVpbnQ4X3Qgb3ZlcmhlYWQpOworZXh0ZXJuIHZvaWQgcnRubF9odGJfc2V0X21w
dShzdHJ1Y3QgcnRubF9jbGFzcyAqLCB1aW50OF90IG1wdSk7CiAKICNpZmRlZiBfX2NwbHVzcGx1
cwogfQotLSAKMS41LjQuMQoK
------=_Part_55950_10709858.1204644612812--
