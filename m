From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 02/11] [QETH]: Use eth_hdr()
Date: Sat, 10 Mar 2007 13:46:02 -0300
Message-ID: <39e6f6c70703100846v1dc43658y7ea1b9055f312b21@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_12143_2714760.1173545162267"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.236]:28180 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767871AbXCJQqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2007 11:46:03 -0500
Received: by wr-out-0506.google.com with SMTP id 70so1683478wra
        for <netdev@vger.kernel.org>; Sat, 10 Mar 2007 08:46:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_12143_2714760.1173545162267
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 drivers/s390/net/qeth_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

------=_Part_12143_2714760.1173545162267
Content-Type: text/x-patch; name=0002-QETH-Use-eth_hdr.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez4a7t4b
Content-Disposition: attachment; filename="0002-QETH-Use-eth_hdr.patch"

RnJvbSAyZDFmMjUyZGUyZTAwNDdlMTYzZjcwYWU3N2UwYTk2YzBhNmY0YzRkIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogU2F0LCAxMCBNYXIgMjAwNyAxMToxMzo1OSAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMDIvMTFdIFtRRVRIXTogVXNlIGV0aF9oZHIoKQoKU2lnbmVkLW9mZi1ieTogQXJuYWxkbyBD
YXJ2YWxobyBkZSBNZWxvIDxhY21lQHJlZGhhdC5jb20+Ci0tLQogZHJpdmVycy9zMzkwL25ldC9x
ZXRoX21haW4uYyB8ICAgIDIgKy0KIDEgZmlsZXMgY2hhbmdlZCwgMSBpbnNlcnRpb25zKCspLCAx
IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMvczM5MC9uZXQvcWV0aF9tYWluLmMg
Yi9kcml2ZXJzL3MzOTAvbmV0L3FldGhfbWFpbi5jCmluZGV4IGYyYjliMWIuLmQ1MDJiNzcgMTAw
NjQ0Ci0tLSBhL2RyaXZlcnMvczM5MC9uZXQvcWV0aF9tYWluLmMKKysrIGIvZHJpdmVycy9zMzkw
L25ldC9xZXRoX21haW4uYwpAQCAtMjM2MSw3ICsyMzYxLDcgQEAgcWV0aF9yZWJ1aWxkX3NrYl9m
YWtlX2xsX2V0aChzdHJ1Y3QgcWV0aF9jYXJkICpjYXJkLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAog
CVFFVEhfREJGX1RFWFQodHJhY2UsNSwic2tiZmtldGgiKTsKIAlza2ItPm1hYy5yYXcgPSBza2It
PmRhdGEgLSBRRVRIX0ZBS0VfTExfTEVOX0VUSDsKIAkvKiB0aGlzIGlzIGEgZmFrZSBldGhlcm5l
dCBoZWFkZXIgKi8KLQlmYWtlX2hkciA9IChzdHJ1Y3QgZXRoaGRyICopIHNrYi0+bWFjLnJhdzsK
KwlmYWtlX2hkciA9IGV0aF9oZHIoc2tiKTsKIAogCS8qIHRoZSBkZXN0aW5hdGlvbiBNQUMgYWRk
cmVzcyAqLwogCXN3aXRjaCAoc2tiLT5wa3RfdHlwZSl7Ci0tIAoxLjUuMC4yCgo=
------=_Part_12143_2714760.1173545162267--
