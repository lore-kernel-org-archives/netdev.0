From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 6/8] net: gre: Implement LCO for GRE over IPv4
Date: Mon, 11 Jan 2016 10:09:55 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCC1D7E@AcuExch.aculab.com>
References: <56901197.8040808@solarflare.com>
 <56901235.1010800@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>,
	"tom@herbertland.com" <tom@herbertland.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
To: 'Edward Cree' <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.183]:55561 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758151AbcAKKMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 05:12:50 -0500
In-Reply-To: <56901235.1010800@solarflare.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRWR3YXJkIENyZWUNCj4gU2VudDogMDggSmFudWFyeSAyMDE2IDE5OjQ3DQouLi4NCj4g
KwlpZiAoc2tiLT5pcF9zdW1tZWQgPT0gQ0hFQ0tTVU1fUEFSVElBTCkgew0KPiArCQljc3VtID0g
Y3N1bV9mb2xkKGxjb19jc3VtKHNrYikpOw0KPiArCQlpZiAoY3N1bSA9PSAwKQ0KPiArCQkJY3N1
bSA9IENTVU1fTUFOR0xFRF8wOw0KPiArCQlyZXR1cm4gY3N1bTsNCj4gKwl9IGVsc2Ugew0KPiAr
CQlyZXR1cm4gY3N1bV9mb2xkKHNrYl9jaGVja3N1bShza2IsIDAsIHNrYi0+bGVuLCAwKSk7DQo+
ICsJfQ0KDQpZb3Ugc2VlIHRvIGJlIHdvcnJpZWQgYWJvdXQgY3N1bV9mb2xkKCkgcmV0dXJuaW5n
IDAgaW4gb25lDQpwYXRoLCBidXQgbm90IGluIHRoZSBvdGhlci4NCkknbSBndWVzc2luZyB0aGF0
IDAgY2FuIG9ubHkgaGFwcGVuIGlmIGFsbCB0aGUgYnl0ZXMgdGhhdCBoYXZlDQpiZWVuIGNoZWNr
c3VtbWVkIGFyZSB6ZXJvLg0KVGhpcyBpcyBhbG1vc3QgY2VydGFpbmx5IG5ldmVyIHRydWUgaWYg
YW55IGJ5dGVzIGhhdmUgYmVlbiBzdW1tZWQsDQphbmQgbWlnaHQgYmUgYmV0dGVyIGF2b2lkZWQg
YnkgaW5pdGlhbGlzaW5nIGFueSBzdWNoIGNoZWNrc3VtIHRvDQoweGZmZmYgKGluc3RlYWQgb2Yg
MCkgbXVjaCBlYXJsaWVyIG9uLg0KDQoJRGF2aWQNCg0K
