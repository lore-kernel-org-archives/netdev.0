From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net-next 1/5] net: local checksum offload for
 encapsulation
Date: Thu, 7 Jan 2016 17:22:51 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCBF46D@AcuExch.aculab.com>
References: <568E9BF9.2050001@solarflare.com>
 <568E9C64.6090305@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>,
	"Tom Herbert" <tom@herbertland.com>
To: 'Edward Cree' <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:50535 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbcAGRZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 12:25:33 -0500
In-Reply-To: <568E9C64.6090305@solarflare.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRWR3YXJkIENyZWUNCj4gU2VudDogMDcgSmFudWFyeSAyMDE2IDE3OjEyDQo+IFRoZSBh
cml0aG1ldGljIHByb3BlcnRpZXMgb2YgdGhlIG9uZXMtY29tcGxlbWVudCBjaGVja3N1bSBtZWFu
IHRoYXQgYQ0KPiAgY29ycmVjdGx5IGNoZWNrc3VtbWVkIGlubmVyIHBhY2tldCwgaW5jbHVkaW5n
IGl0cyBjaGVja3N1bSwgaGFzIGEgb25lcw0KPiAgY29tcGxlbWVudCBzdW0gZGVwZW5kaW5nIG9u
bHkgb24gd2hhdGV2ZXIgdmFsdWUgd2FzIHVzZWQgdG8gaW5pdGlhbGlzZQ0KPiAgdGhlIGNoZWNr
c3VtIGZpZWxkIGJlZm9yZSBjaGVja3N1bW1pbmcgKGluIHRoZSBjYXNlIG9mIFRDUCBhbmQgVURQ
LA0KPiAgdGhpcyBpcyB0aGUgb25lcyBjb21wbGVtZW50IHN1bSBvZiB0aGUgcHNldWRvIGhlYWRl
ciwgY29tcGxlbWVudGVkKS4NCj4gQ29uc2VxdWVudGx5LCBpZiB3ZSBhcmUgZ29pbmcgdG8gb2Zm
bG9hZCB0aGUgaW5uZXIgY2hlY2tzdW0gd2l0aA0KPiAgQ0hFQ0tTVU1fUEFSVElBTCwgd2UgY2Fu
IGNvbXB1dGUgdGhlIG91dGVyIGNoZWNrc3VtIGJhc2VkIG9ubHkgb24gdGhlDQo+ICBwYWNrZWQg
ZGF0YSBub3QgY292ZXJlZCBieSB0aGUgaW5uZXIgY2hlY2tzdW0sIGFuZCB0aGUgaW5pdGlhbCB2
YWx1ZSBvZg0KPiAgdGhlIGlubmVyIGNoZWNrc3VtIGZpZWxkLg0KDQpJc24ndCBpdCBldmVuIHNp
bXBsZXIgdGhhbiB0aGF0Pw0KVGhlIGNoZWNrc3VtIG9mIHRoZSBpbm5lciBwYWNrZXQgKGluY2x1
ZGluZyBpdHMgaGVhZGVyKSBpcyB+MCAoaWUgMCkuDQpTbyB0aGUgY2hlY2tzdW0gb2YgdGhlIHdo
b2xlIHBhY2tldCAoZm9yIHRoZSBvdXRlciBoZWFkZXIpIGlzIHRoZSBzYW1lDQphcyB0aGF0IG9m
IHRoZSBwYWNrZXQgZG93biB0byB0aGUgc3RhcnQgb2YgdGhlIGlubmVyIGhlYWRlci4NCg0KCURh
dmlkDQoNCg==
