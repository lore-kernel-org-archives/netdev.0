From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 0/5] XFRM,IPv6: Removal of RH2/HAO from
 IPsec-protected MIPv6 traffic
Date: Mon, 27 Sep 2010 21:25:41 -0700 (PDT)
Message-ID: <20100927.212541.183056184.davem@davemloft.net>
References: <87bp7nrlvy.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: eric.dumazet@gmail.com, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: arno@natisbad.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39990
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750702Ab0I1EZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 00:25:21 -0400
In-Reply-To: <87bp7nrlvy.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQpQbGVhc2UgcmVzdWJtaXQgdGhpcyBhZnRlciB5b3UndmUgZG9uZSBzb21lIG1vcmUgZXhoYXVz
dGl2ZQ0KYnVpbGQgdGVzdGluZzoNCg0KLS0tDQpuZXQvaXB2Ni94ZnJtNl9pbnB1dC5jOiBJbiBm
dW5jdGlvbiCheGZybTZfaW5wdXRfYWRkcl9jaGVja6I6DQpuZXQvaXB2Ni94ZnJtNl9pbnB1dC5j
OjE3MzogZXJyb3I6IGltcGxpY2l0IGRlY2xhcmF0aW9uIG9mIGZ1bmN0aW9uIKFpcHY2X2Noa19o
b21lX2FkZHKiDQpuZXQvaXB2Ni94ZnJtNl9pbnB1dC5jOjE3OTogZXJyb3I6IKFzdHJ1Y3Qgc2Vj
X3BhdGiiIGhhcyBubyBtZW1iZXIgbmFtZWQgoWlyb2RzdKINCm5ldC9pcHY2L3hmcm02X2lucHV0
LmM6MjAyOiBlcnJvcjogoXN0cnVjdCBzZWNfcGF0aKIgaGFzIG5vIG1lbWJlciBuYW1lZCChaXJv
c3Jjog0KLS0tDQpkYXZlbUBzdW5zZXQ6fi9zcmMvR0lUL25ldC1uZXh0LTIuNiQgZWdyZXAgWEZS
TSAuY29uZmlnDQpDT05GSUdfWEZSTT15DQpDT05GSUdfWEZSTV9VU0VSPW0NCiMgQ09ORklHX1hG
Uk1fU1VCX1BPTElDWSBpcyBub3Qgc2V0DQpDT05GSUdfWEZSTV9NSUdSQVRFPXkNCiMgQ09ORklH
X1hGUk1fU1RBVElTVElDUyBpcyBub3Qgc2V0DQpDT05GSUdfWEZSTV9JUENPTVA9eQ0KQ09ORklH
X0lORVRfWEZSTV9UVU5ORUw9eQ0KQ09ORklHX0lORVRfWEZSTV9NT0RFX1RSQU5TUE9SVD15DQpD
T05GSUdfSU5FVF9YRlJNX01PREVfVFVOTkVMPXkNCkNPTkZJR19JTkVUX1hGUk1fTU9ERV9CRUVU
PXkNCkNPTkZJR19JTkVUNl9YRlJNX1RVTk5FTD1tDQpDT05GSUdfSU5FVDZfWEZSTV9NT0RFX1RS
QU5TUE9SVD1tDQpDT05GSUdfSU5FVDZfWEZSTV9NT0RFX1RVTk5FTD1tDQpDT05GSUdfSU5FVDZf
WEZSTV9NT0RFX0JFRVQ9bQ0KIyBDT05GSUdfSU5FVDZfWEZSTV9NT0RFX1JPVVRFT1BUSU1JWkFU
SU9OIGlzIG5vdCBzZXQNCmRhdmVtQHN1bnNldDp+L3NyYy9HSVQvbmV0LW5leHQtMi42JCANCg==
