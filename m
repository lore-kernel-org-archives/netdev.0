From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [RFC 1/2] net/ethtool: Add new coalescing parameter for queue
Date: Tue, 8 Dec 2015 19:39:57 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F077019AA93C@SHSMSX103.ccr.corp.intel.com>
References: <1449549750-12448-1-git-send-email-kan.liang@intel.com>
 <CAP-MU4OHMz8DaMwvF7=0ZgMCFdW0_85KH5O5ke55-X6Ox1Vw2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"bwh@kernel.org" <bwh@kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"sasha.levin@oracle.com" <sasha.levin@oracle.com>,
	"dsahern@gmail.com" <dsahern@gmail.com>,
	"tj@kernel.org" <tj@kernel.org
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:9367 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752282AbbLHTkE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 14:40:04 -0500
In-Reply-To: <CAP-MU4OHMz8DaMwvF7=0ZgMCFdW0_85KH5O5ke55-X6Ox1Vw2Q@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCg0KPiANCj4gRm9yIHRoYXQgbWF0dGVyLCBpZiB5b3UndmUgc2V0IGRpZmZlcmVudCBjb2Fs
ZXNjZSB2YWx1ZXMgb24gdmFyaW91cyBxdWV1ZXMsDQo+IHdoYXQgZG9lcyBhc2tpbmcgZm9yICct
MScgb3IgImFsbCB0aGUgcXVldWVzIiBtZWFuIGFuZCBob3cgc2hvdWxkIGl0IHJldHVybg0KPiBp
bmZvPyBTaG91bGRuJ3QgYWxsIHRoZSBzcGVjaWZpYyBxdWV1ZXMgYmUgc2hvd24/ICBPciBkbyB3
ZSBub3cgaGF2ZSB0bw0KPiBkbyBhbiBldGh0b29sIGNvbW1hbmQgZm9yIGVhY2ggYW5kIGV2ZXJ5
IHF1ZXVlPw0KPg0KDQpUaGUgb25seSB3YXkgdG8gc2hvdyB0aGUgdmFsdWUgb2Ygc3BlY2lmaWMg
cXVldWUgaXMgdG8gYXBwbHkgcXVldWUgb3B0aW9uLA0KbGlrZSAiZXRodG9vbCAtYyBERVZOQU1F
IHF1ZXVlIE4iDQpJZiB1c2luZyAiYWxsIHRoZSBxdWV1ZXMiLCB0aGUgbGFzdCB2YWx1ZSB3aGlj
aCBzZXQgYnkgZXRodG9vbCAtQyB3aWxsIGJlDQpzaG93bi4gIA0KDQpZZXMsICJhbGwgdGhlIHF1
ZXVlcyIgaXMgbWlzbGVhZGluZy4gSSB0aGluayB3ZSBtYXkgZm9yY2UgdXNlciB0byBzcGVjaWZ5
IHRoZQ0KcXVldWUgd2hlbiB1c2luZyAtLXNob3ctY29hbGVzY2UuIFF1ZXVlIDAgaXMgdGhlIGRl
ZmF1bHQgcXVldWUuDQpJZiB3ZSByZWFsbHkgd2FudCB0byBzaG93IGFsbCBxdWV1ZXMgYnkgZGVm
YXVsdCwgd2UgbWF5IG5lZWQgdG8NCmNoYW5nZSB0aGUgZXRodG9vbF9nZXRfY29hbGVzY2UgaW50
ZXJmYWNlLiBIb3dldmVyLCB0aGF0IHdpbGwgaW1wYWN0IGFsbA0Kb3RoZXIgZHJpdmVycy4NCkkn
bSBub3Qgc3VyZSB3aGljaCBvbmUgaXMgYmV0dGVyLg0KDQpUaGFua3MsDQpLYW4NCg0K
