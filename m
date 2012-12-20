From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: TCP delayed ACK heuristic
Date: Thu, 20 Dec 2012 09:57:27 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70FC@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B70F4@saturn3.aculab.com> <1355900436.6665.16.camel@cr0> <50D209E9.2000504@hp.com> <20121219.125939.1674292599518627751.davem@davemloft.net> <1355973829.25310.5.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <rick.jones2@hp.com>, <netdev@vger.kernel.org>,
	<greearb@candelatech.com>, <eric.dumazet@gmail.com>,
	<shemminger@vyatta.com>, <tgraf@redhat.com>
To: "Cong Wang" <amwang@redhat.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53697 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750977Ab2LTKKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 05:10:12 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 16280-10 for <netdev@vger.kernel.org>;
 Thu, 20 Dec 2012 10:10:07 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1355973829.25310.5.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBTbywgY2FuIHdlIGF0IGxlYXN0IGhhdmUgYSBzeXNjdGwgdG8gY29udHJvbCB0aGUgdGltZW91
dCBvZiB0aGUgZGVsYXllZA0KPiBBQ0s/IEkgbWVhbiB0aGUgbWluaW11bSA0MG1zLiBUQ1BfUVVJ
Q0tBQ0sgY2FuIGhlbHAgdG9vLCBidXQgaXQgcmVxdWlyZXMNCj4gdGhlIHJlY2VpdmVyIHRvIG1v
ZGlmeSB0aGUgYXBwbGljYXRpb24gYW5kIGhhcyB0byBiZSBzZXQgZXZlcnkgdGltZSB3aGVuDQo+
IGNhbGxpbmcgcmVjdigpLg0KDQpBIHN5c2N0bCBpbiBpbmFwcHJvcHJpYXRlIC0gaXQgYWZmZWN0
cyB0aGUgZW50aXJlIFRDUCBwcm90b2NvbCBzdGFjay4NCg0KWW91IHdhbnQgZGlmZmVyZW50IGJl
aGF2aW91ciBmb3IgZGlmZmVyZW50IHJlbW90ZSBob3N0cyAocHJvYmFibHkNCmRpZmZlcmVudCBz
dWJuZXRzKS4NCkluIHBhcnRpY3VsYXIgeW91ciBsb2NhbCBzdWJuZXQgaXMgdW5saWtlbHkgdG8g
aGF2ZSBwYWNrZXQgbG9zcw0KYW5kIHZlcnkgbGlrZWx5IHRvIGhhdmUgYSB2ZXJ5IGxvdyBSVFQu
DQoNCkFGQUlDVCBhIGxvdCBvZiB0aGUgcmVjZW50ICd0dW5pbmcnIGhhcyBiZWVuIGRvbmUgZm9y
IHdlYi9mdHANCnNlcnZlcnMgdGhhdCBhcmUgdmVyeSByZW1vdGUgZnJvbSB0aGUgY2xpZW50LiBU
aGVzZSBjb25uZWN0aW9ucw0KYXJlIGFsc28gcmVxdWVzdC1yZXNwb25zZSBvbmVzIC0gcXVpdGUg
b2Z0ZW4gd2l0aCBsYXJnZSByZXNwb25zZXMuDQoNCklNSE8gVGhpcyBoYXMgYmVlbiB0byB0aGUg
ZGV0cmltZW50IG9mIGxvY2FsIGNvbm5lY3Rpb25zLg0KDQoJRGF2aWQNCg0K
