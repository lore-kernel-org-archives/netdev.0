From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 17/18][SK_BUFF] ipmr: Another skb_push related conversion to skb_reset_network_header
Date: Mon, 12 Mar 2007 01:28:08 -0300
Message-ID: <39e6f6c70703112128y5768cfc9ha3ac36da553436f8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_27612_27682812.1173673688920"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:50832 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965075AbXCLE2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 00:28:10 -0400
Received: by ug-out-1314.google.com with SMTP id 44so2091317uga
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2007 21:28:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_27612_27682812.1173673688920
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/ipv4/ipmr.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

------=_Part_27612_27682812.1173673688920
Content-Type: text/x-patch;
	name=0017-SK_BUFF-ipmr-Another-skb_push-related-conversion.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez6ehtet
Content-Disposition: attachment; filename="0017-SK_BUFF-ipmr-Another-skb_push-related-conversion.patch"

RnJvbSA5OGVkNjljYWJjNWQwNmI2NWQzNGQ4ZmE3NzlhYWNlYzc5MWQ0ZWYzIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogU3VuLCAxMSBNYXIgMjAwNyAyMjozODoyOSAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMTcvMThdIFtTS19CVUZGXSBpcG1yOiBBbm90aGVyIHNrYl9wdXNoIHJlbGF0ZWQgY29udmVy
c2lvbiB0byBza2JfcmVzZXRfbmV0d29ya19oZWFkZXIKClNpZ25lZC1vZmYtYnk6IEFybmFsZG8g
Q2FydmFsaG8gZGUgTWVsbyA8YWNtZUByZWRoYXQuY29tPgotLS0KIG5ldC9pcHY0L2lwbXIuYyB8
ICAgIDYgKysrKy0tCiAxIGZpbGVzIGNoYW5nZWQsIDQgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlv
bnMoLSkKCmRpZmYgLS1naXQgYS9uZXQvaXB2NC9pcG1yLmMgYi9uZXQvaXB2NC9pcG1yLmMKaW5k
ZXggNGE4ZDk5Yi4uNDY1NDU5ZCAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvaXBtci5jCisrKyBiL25l
dC9pcHY0L2lwbXIuYwpAQCAtNTYxLDggKzU2MSwxMCBAQCBzdGF0aWMgaW50IGlwbXJfY2FjaGVf
cmVwb3J0KHN0cnVjdCBza19idWZmICpwa3QsIHZpZmlfdCB2aWZpLCBpbnQgYXNzZXJ0KQogCQkg
ICBBbmQgYWxsIHRoaXMgb25seSB0byBtYW5nbGUgbXNnLT5pbV9tc2d0eXBlIGFuZAogCQkgICB0
byBzZXQgbXNnLT5pbV9tYnogdG8gIm1ieiIgOi0pCiAJCSAqLwotCQltc2cgPSAoc3RydWN0IGln
bXBtc2cqKXNrYl9wdXNoKHNrYiwgc2l6ZW9mKHN0cnVjdCBpcGhkcikpOwotCQlza2ItPm5oLnJh
dyA9IHNrYi0+aC5yYXcgPSAodTgqKW1zZzsKKwkJc2tiX3B1c2goc2tiLCBzaXplb2Yoc3RydWN0
IGlwaGRyKSk7CisJCXNrYl9yZXNldF9uZXR3b3JrX2hlYWRlcihza2IpOworCQlza2ItPmgucmF3
ID0gc2tiLT5kYXRhOworCQltc2cgPSAoc3RydWN0IGlnbXBtc2cgKilza2ItPm5oLnJhdzsKIAkJ
bWVtY3B5KG1zZywgc2tiX25ldHdvcmtfaGVhZGVyKHBrdCksIHNpemVvZihzdHJ1Y3QgaXBoZHIp
KTsKIAkJbXNnLT5pbV9tc2d0eXBlID0gSUdNUE1TR19XSE9MRVBLVDsKIAkJbXNnLT5pbV9tYnog
PSAwOwotLSAKMS41LjAuMgoK
------=_Part_27612_27682812.1173673688920--
