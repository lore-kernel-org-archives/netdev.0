From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 10/11] [TCP]: Use skb_set_mac_header in tcp_collapse
Date: Sat, 10 Mar 2007 13:46:37 -0300
Message-ID: <39e6f6c70703100846k656735a2kcd24f4e946337813@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_12195_10052285.1173545197848"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:35905 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767874AbXCJQqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2007 11:46:38 -0500
Received: by an-out-0708.google.com with SMTP id b33so1053757ana
        for <netdev@vger.kernel.org>; Sat, 10 Mar 2007 08:46:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_12195_10052285.1173545197848
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

------=_Part_12195_10052285.1173545197848
Content-Type: text/x-patch;
	name=0010-TCP-Use-skb_set_mac_header-in-tcp_collapse.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez4agshm
Content-Disposition: attachment; filename="0010-TCP-Use-skb_set_mac_header-in-tcp_collapse.patch"

RnJvbSBjMWNlOWZiNmNmZGY2ZGEyYWVmNmNlMjllOWQ2OTU0ZDgxZWJjNDEwIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogU2F0LCAxMCBNYXIgMjAwNyAxMjo0ODozNyAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMTAvMTFdIFtUQ1BdOiBVc2Ugc2tiX3NldF9tYWNfaGVhZGVyIGluIHRjcF9jb2xsYXBzZQoK
U2lnbmVkLW9mZi1ieTogQXJuYWxkbyBDYXJ2YWxobyBkZSBNZWxvIDxhY21lQHJlZGhhdC5jb20+
Ci0tLQogbmV0L2lwdjQvdGNwX2lucHV0LmMgfCAgICAyICstCiAxIGZpbGVzIGNoYW5nZWQsIDEg
aW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9uZXQvaXB2NC90Y3Bf
aW5wdXQuYyBiL25ldC9pcHY0L3RjcF9pbnB1dC5jCmluZGV4IGU1ZDFjMmMuLjFlYzA1YmQgMTAw
NjQ0Ci0tLSBhL25ldC9pcHY0L3RjcF9pbnB1dC5jCisrKyBiL25ldC9pcHY0L3RjcF9pbnB1dC5j
CkBAIC0zNjMzLDcgKzM2MzMsNyBAQCB0Y3BfY29sbGFwc2Uoc3RydWN0IHNvY2sgKnNrLCBzdHJ1
Y3Qgc2tfYnVmZl9oZWFkICpsaXN0LAogCQlpZiAoIW5za2IpCiAJCQlyZXR1cm47CiAKLQkJbnNr
Yi0+bWFjLnJhdyA9IG5za2ItPmRhdGEgKyAoc2tiLT5tYWMucmF3IC0gc2tiLT5oZWFkKTsKKwkJ
c2tiX3NldF9tYWNfaGVhZGVyKG5za2IsIHNrYi0+bWFjLnJhdyAtIHNrYi0+aGVhZCk7CiAJCW5z
a2ItPm5oLnJhdyA9IG5za2ItPmRhdGEgKyAoc2tiLT5uaC5yYXcgLSBza2ItPmhlYWQpOwogCQlu
c2tiLT5oLnJhdyA9IG5za2ItPmRhdGEgKyAoc2tiLT5oLnJhdyAtIHNrYi0+aGVhZCk7CiAKLS0g
CjEuNS4wLjIKCg==
------=_Part_12195_10052285.1173545197848--
