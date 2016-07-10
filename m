From: Moshe Shemesh <moshe@mellanox.com>
Subject: RE: [PATCH net-next 1/4] net/mlx4_core: Fix QUERY FUNC CAP flags
Date: Sun, 10 Jul 2016 09:30:52 +0000
Message-ID: <AM4PR0501MB22288D8E5D7AA47D441D83E6D93E0@AM4PR0501MB2228.eurprd05.prod.outlook.com>
References: <CAJ3xEMhgDG4iWL+ZD07R-ynCXqfY0RARuP5oCFsjXLS1H3uA5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	"Hadar Hen Zion" <hadarh@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>,
	Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0051.outbound.protection.outlook.com ([104.47.2.51]:19616
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753584AbcGJNEv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2016 09:04:51 -0400
In-Reply-To: <CAJ3xEMhgDG4iWL+ZD07R-ynCXqfY0RARuP5oCFsjXLS1H3uA5g@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQo+T24gV2VkLCBKdWwgNiwgMjAxNiBhdCAzOjI5IFBNLCBUYXJpcSBUb3VrYW4gPHRhcmlxdEBt
ZWxsYW5veC5jb20+IHdyb3RlOg0KPj4gRnJvbTogTW9zaGUgU2hlbWVzaCA8bW9zaGVAbWVsbGFu
b3guY29tPg0KPj4NCj4+IFNlcGFyYXRlIFFVRVJZX0ZVTkNfQ0FQIGZsYWdzMCBmcm9tIFFVRVJZ
X0ZVTkNfQ0FQIGZsYWdzLg0KPj4gUmVtb3ZlIFFVRVJZX0ZVTkNfQ0FQIHBvcnRfZmxhZ3MgZmll
bGQgd2hpY2ggd2FzIG5vdCBpbiB1c2UuDQo+DQo+VGhlIHBhdGNoIHRpdGxlIHNheXMgIkZpeCAu
Li4iIGJ1dCB0aGUgY2hhbmdlIGxvZyBkb2Vzbid0IHNheSBpZiB0aGlzIGlzIGZpeGluZyByZWFs
IGJ1Zywgb3IgY2xlYW5pbmcgdXAgZGVhZCA+Y29kZSwgbm9yIHlvdSBwb2ludCB0byB0aGUgY29t
bWl0IHlvdSBhcmUgZml4aW5nLCBwbGVhc2UgYWRkIHRoYXQsIEkgZ3Vlc3MgaXQgaXMgc29tZXRo
aW5nIHdlIGRvIHdyb25nID53LnIudCB0aGUgUEhWIGJpdCBidXQgSSBhbSBub3QgY2xlYXIgd2hh
dC4NCg0KQm90aCBkZWFkIGNvZGUgYW5kIGEgYnVnOg0KT25lIHBhcnQgaXMgcmVtb3ZpbmcgZGVh
ZCBjb2RlICh1bnVzZWQgZmllbGQgLSBwb3J0X2ZsYWdzKS4NCiJSZW1vdmUgUVVFUllfRlVOQ19D
QVAgcG9ydF9mbGFncyBmaWVsZCB3aGljaCB3YXMgbm90IGluIHVzZS4iIA0KDQpUaGUgb3RoZXIg
cGFydCBpcyBmaXhpbmcgYSBidWcsIGFzICJmbGFncyIgaXMgYWxyZWFkeSB1c2VkIGZvciBvdGhl
ciBzZXQgb2YgZmxhZ3MgaW4gRnVuYyBjYXAsIHdoaWxlIHBodiBiaXQgc2hvdWxkIGJlIHBhcnQg
b2YgYSBkaWZmZXJlbnQgc2V0IG9mIGZsYWdzICJmbGFnczAiLg0KIlNlcGFyYXRlIFFVRVJZX0ZV
TkNfQ0FQIGZsYWdzMCBmcm9tIFFVRVJZX0ZVTkNfQ0FQIGZsYWdzLiIgDQoNCldlIHdpbGwgc3Vi
bWl0IHYyIHdpdGggYW4gdXBkYXRlZCBjb21taXQgbWFzc2FnZSBpbmNsdWRpbmcgdGhlIHJlbGV2
YW50IEZpeGVzIGxpbmVzLg0KDQpSZWdhcmRzLA0KTW9zaGUuDQoNCg==
