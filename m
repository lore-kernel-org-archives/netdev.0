From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] veth: remove unneeded ifname code from
 veth_newlink()
Date: Thu, 28 Apr 2011 13:27:24 -0700 (PDT)
Message-ID: <20110428.132724.48500963.davem@davemloft.net>
References: <20110124154546.GA2689@psychotron.brq.redhat.com>
	<BANLkTi=x8xi7-g3SZdva7Ndg0a4EY1NK8g@mail.gmail.com>
	<BANLkTikUAGWhNnCrebQpVttorqVxfD6KWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: jpirko@redhat.com, netdev@vger.kernel.org, xemul@openvz.org
To: mirqus@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60615
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751171Ab1D1U15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 16:27:57 -0400
In-Reply-To: <BANLkTikUAGWhNnCrebQpVttorqVxfD6KWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTWljaGHFgiBNaXJvc8WCYXcgPG1pcnF1c0BnbWFpbC5jb20+DQpEYXRlOiBGcmksIDIy
IEFwciAyMDExIDExOjQ5OjQwICswMjAwDQoNCj4gVyBkbml1IDIyIGt3aWV0bmlhIDIwMTEgMTE6
NDMgdcW8eXRrb3duaWsgTWljaGHFgiBNaXJvc8WCYXcNCj4gPG1pcnF1c0BnbWFpbC5jb20+IG5h
cGlzYcWCOg0KPj4gMjAxMS8xLzI0IEppcmkgUGlya28gPGpwaXJrb0ByZWRoYXQuY29tPjoNCj4+
PiBUaGUgY29kZSBpcyBub3QgbmVlZGVkIGJlY2F1c2UgdGJbSUZMQV9JRk5BTUVdIGlzIGFscmVh
ZHkNCj4+PiBwcm9jZXNzZWQgaW4gcnRubF9uZXdsaW5rKCkuIFJlbW92ZSB0aGlzIHJlZHVuZGFu
Y3kuDQo+PiBIaS4gVGhpcyBwYXRjaCBicm9rZSBjcmVhdGlvbiBvZiB2ZXRoIGRldmljZXMuIFJl
dmVydGluZyBpdCBmaXhlcyB0aGUgaXNzdWUuDQo+Pg0KPj4gU3ltcHRvbXM6DQo+Pg0KPj4gaWN5
Ym94On4jIGlwIGxpbmsgYWRkIHR5cGUgdmV0aA0KPj4gUlRORVRMSU5LIGFuc3dlcnM6IEZpbGUg
ZXhpc3RzDQo+PiBpY3lib3g6fiMgaXAgbGluayBhZGQgdHlwZSB2ZXRoIHBlZXIgdmV0aDENCj4+
IGljeWJveDp+IyBpcCBhZGRyDQo+PiBbLi4uXQ0KPj4gNTY6IEQ6IDxCUk9BRENBU1QsTVVMVElD
QVNUPiBtdHUgMTUwMCBxZGlzYyBub29wIHN0YXRlIERPV04gcWxlbiAxMDAwDQo+PiDCoCDCoGxp
bmsvZXRoZXIgZTY6NTc6NTg6NTI6MDM6NTAgYnJkIGZmOmZmOmZmOmZmOmZmOmZmDQo+PiA1Nzog
dmV0aDA6IDxCUk9BRENBU1QsTVVMVElDQVNUPiBtdHUgMTUwMCBxZGlzYyBub29wIHN0YXRlIERP
V04gcWxlbiAxMDAwDQo+PiDCoCDCoGxpbmsvZXRoZXIgYzI6YzI6YTI6ZDU6ZDU6M2EgYnJkIGZm
OmZmOmZmOmZmOmZmOmZmDQo+IA0KPiBIbW0uIEkgd2FzIHRvbyBxdWljay4gUmV2ZXJ0aW5nIGl0
IGZpeGVzIG9ubHkgZmlyc3QgcHJvYmxlbSAtICJpcCBsaW5rDQo+IGFkZCB0eXBlIHZldGgiIGFk
ZHMgbmV3IHZldGggcGFpciBub3csIGJ1dCAiaXAgbGluayBhZGQgdHlwZSB2ZXRoIHBlZXINCj4g
dmV0aDEiIGdpdmVzIHRoZSBzYW1lIHJlc3VsdCBhcyBhYm92ZS4NCg0KSmlyaSBwbGVhc2UgbG9v
ayBpbnRvIHRoaXMgcmVncmVzc2lvbi4NCg==
