From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [PATCH] net: add additional lock to qdisc to increase throughput
Date: Fri, 21 May 2010 13:04:20 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F256284B068@orsmsx501.amr.corp.intel.com>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
 <1274454480.2439.418.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:20724 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752382Ab0EUUEY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 May 2010 16:04:24 -0400
In-Reply-To: <1274454480.2439.418.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RXJpYyBEdW1hemV0IHdyb3RlOg0KPiBUZXN0cyB3aXRoIGZvbGxvd2luZyBzY3JpcHQgZ2F2ZSBh
IGJvb3N0IGZyb20gfjUwLjAwMCBwcHMgdG8gfjYwMC4wMDANCj4gcHBzIG9uIGEgZHVhbCBxdWFk
IGNvcmUgbWFjaGluZSAoRTU0NTAgQDMuMDBHSHopLCB0ZzMgZHJpdmVyLg0KPiAoQSBzaW5nbGUg
bmV0cGVyZiBmbG93IGNhbiByZWFjaCB+ODAwLjAwMCBwcHMgb24gdGhpcyBwbGF0Zm9ybSkNCj4g
DQo+IGZvciBqIGluIGBzZXEgMCAzYDsgZG8NCj4gICBmb3IgaSBpbiBgc2VxIDAgN2A7IGRvDQo+
ICAgICBuZXRwZXJmIC1IIDE5Mi4xNjguMC4xIC10IFVEUF9TVFJFQU0gLWwgNjAgLU4gLVQgJGkg
LS0gLW0gNiAmDQo+ICAgZG9uZQ0KPiBkb25lDQoNClJ1bm5pbmcgdGhlIHNhbWUgc2NyaXB0IHdp
dGggeW91ciBwYXRjaCBteSByZXN1bHRzIHdlbnQgZnJvbSAyMDBLcHBzIHRvIDEuMk1wcHMgb24g
YSBkdWFsIFhlb24gNTU3MC4NCg0KQWNrZWQtYnk6IEFsZXhhbmRlciBEdXljayA8YWxleGFuZGVy
LmguZHV5Y2tAaW50ZWwuY29tPg0KDQo=
