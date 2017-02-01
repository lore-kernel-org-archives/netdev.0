From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 1/8] net/mlx5: Fixed static checker warnings
Date: Wed, 1 Feb 2017 17:02:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0277E67@AcuExch.aculab.com>
References: <20170131205843.23235-1-saeedm@mellanox.com>
 <20170131205843.23235-2-saeedm@mellanox.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0277BE3@AcuExch.aculab.com>
 <CAJ3xEMgKUTGCr+AXuHgEm_r=KpMf0mEyp8sxC4o1PF3p9KjMRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Or Gerlitz" <ogerlitz@mellanox.com>,
        Matan Barak <matanb@mellanox.com>
To: 'Or Gerlitz' <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.191]:61814 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753232AbdBARDP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 12:03:15 -0500
In-Reply-To: <CAJ3xEMgKUTGCr+AXuHgEm_r=KpMf0mEyp8sxC4o1PF3p9KjMRA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogT3IgR2VybGl0eg0KPiBTZW50OiAwMSBGZWJydWFyeSAyMDE3IDE2OjQwDQo+IE9uIFdl
ZCwgRmViIDEsIDIwMTcgYXQgMToxNyBQTSwgRGF2aWQgTGFpZ2h0IDxEYXZpZC5MYWlnaHRAYWN1
bGFiLmNvbT4gd3JvdGU6DQo+ID4gRnJvbTogU2FlZWQgTWFoYW1lZWQNCj4gPj4gU2VudDogMzEg
SmFudWFyeSAyMDE3IDIwOjU5DQo+ID4+IEZyb206IE9yIEdlcmxpdHogPG9nZXJsaXR6QG1lbGxh
bm94LmNvbT4NCj4gPj4NCj4gPj4gRm9yIHNvbWUgcmVhc29uLCBzcGFyc2UgZG9lc24ndCBsaWtl
IHVzaW5nIGFuIGV4cHJlc3Npb24gb2YgdHlwZSAoIXgpDQo+ID4+IHdpdGggYSBiaXR3aXNlIHwg
YW5kICYuICBJbiBvcmRlciB0byBtaXRpZ2F0ZSB0aGF0LCB3ZSB1c2UgYSBsb2NhbA0KPiA+PiB2
YXJpYWJsZS4NCj4gPj4NCj4gPj4gU2luY2UgZ2V0dGluZyBhIHR5cGVvZihiaXRmaWVsZCkgaXMg
aW5jb3JyZWN0LCB3ZSBjYXN0IHN1Y2ggY2FzZXMuDQo+ID4gLi4uDQo+ID4+ICsgICAgICAgICAg
ICAgICAgICAgICBNTFg1X1NFVChmdGVfbWF0Y2hfc2V0X2x5cl8yXzQsIGhlYWRlcnNfYywgZmly
c3RfcHJpbywgKHU4KW1hc2stDQo+ID52bGFuX3ByaW9yaXR5KTsNCj4gPg0KPiA+IFVnZyBuYXN0
eSBjYXN0cy4uLg0KPiA+IC4uLg0KPiA+PiAgI2RlZmluZSBNTFg1X1NFVCh0eXAsIHAsIGZsZCwg
dikgZG8geyBcDQo+ID4+ICsgICAgIHR5cGVvZih2KSBfdiA9IHY7IFwNCj4gPiAuLg0KPiA+DQo+
ID4gV2h5IG5vdCBqdXN0ICd1bnNpZ25lZCBpbnQgX3YgPSB2Ow0KPiANCj4gWWVhaCwgYmFzaWNh
bGx5IHdlIGNvdWxkIGhhdmUgYWxsb2NhdGUgKHVzZSkgdGhlIG1heCBzaXplIGFuZCBhc3NpZ24u
DQo+IFdlIHByZWZlcnJlZCB0byBhbGxvY2F0ZSB0aGUgc3BlY2lmaWMgaW5zdGFuY2Ugc2l6ZSBh
bmQgdXNlIHRoaXMsIGFzIHVzaW5nIHQNCj4gaGUgcmVxdWlyZWQgc2l6ZSBpcyBjbGVhbmVyLg0K
DQpEb2Vzbid0IG1ha2UgYSBibGluZCBiaXQgb2YgZGlmZmVyZW5jZS4NClRoZSB2YWx1ZSBpcyBw
cm9tb3RlZCB0byAnaW50JyBiZWZvcmUgYmVpbmcgdXNlZCBpbiB0aGUgZXhwcmVzc2lvbi4NCllv
dSBtaWdodCBhcyB3ZWxsIGRvIHRoZSBwcm9tb3Rpb24gZWFybGllci4NCg0KCURhdmlkDQoNCg==
