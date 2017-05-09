From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: sky2: Use seq_putc() in sky2_debug_show()
Date: Tue, 9 May 2017 14:26:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFE7F45@AcuExch.aculab.com>
References: <1f36d45e-3ca9-bfb8-0634-901c42390e2c@users.sourceforge.net>
        <8594c152-68a4-c0c7-b4c6-49c753b0c748@gmx.de>
        <a85959a8-a357-d8e0-d7e9-617e2052aed6@users.sourceforge.net>
 <20170508225012.508f24c0@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Mirko Lindner <mlindner@marvell.com>,
        LKML <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: 'Stephen Hemminger' <stephen@networkplumber.org>,
        SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170508225012.508f24c0@xeon-e3>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogU3RlcGhlbiBIZW1taW5nZXINCj4gU2VudDogMDkgTWF5IDIwMTcgMDY6NTANCj4gT24g
TW9uLCA4IE1heSAyMDE3IDE5OjQyOjQ2ICswMjAwDQo+IFNGIE1hcmt1cyBFbGZyaW5nIDxlbGZy
aW5nQHVzZXJzLnNvdXJjZWZvcmdlLm5ldD4gd3JvdGU6DQo+IA0KPiA+ID4gV2hpY2ggaXNzdWUg
ZG8geW91IG1lYW4/IEkgZG9udCBzZWUgYW55IGlzc3VlIHlvdSBmaXggaGVyZS4NCj4gPg0KPiA+
IEFyZSB0aGUgcnVuIHRpbWUgY2hhcmFjdGVyaXN0aWNzIGEgYml0IG5pY2VyIGZvciB0aGUgZnVu
Y3Rpb24gc2VxX3B1dGMNCj4gPiBpbiBjb21wYXJpc29uIHRvIHRoZSBmdW5jdGlvbiBzZXFfcHV0
cyBmb3IgcHJpbnRpbmcgYSBzaW5nbGUgbGluZSBicmVhayBoZXJlPw0KPiA+DQo+ID4gUmVnYXJk
cywNCj4gPiBNYXJrdXMNCj4gDQo+IEkgd291bGQgcHV0IHRoaXMgaW4gd2h5IGJvdGhlciBjYXRl
Z29yeS4gc2VxX3B1dHMgaXMgY29ycmVjdCBhbmQgdGhpcyBpcyBvbmx5DQo+IGluIGRpYWdub3N0
aWMgb3V0cHV0IHVzZWZ1bCB0byBkZXZlbG9wZXIgYW5kIGRpc2FibGVkIG9uIG1vc3QgZGlzdHJv
IGtlcm5lbHMNCg0KU29tZXRpbWVzIGNvbnNpc3RlbmN5IGlzIGJlc3QuDQpPdXRwdXQgZXZlcnl0
aGluZyB3aXRoIHNlcV9wcmludGYoKSwgdXNpbmcgYSBmb3JtYXQgIiVzIiBpZiBuZWNlc3Nhcnku
DQpUaGUgcGVyZm9ybWFuY2UgcmVhbGx5IGRvZXNuJ3QgbWF0dGVyIGhlcmUgYXQgYWxsLg0KDQpJ
dCBpcyBhbHNvIChwcm9iYWJseSkgcG9zc2libGUgdG8gZ2V0IGdjYyB0byBkbyB0aGUgY29udmVy
c2lvbnMgLSBhcyBpdCBkb2VzIGZvciBwcmludGYoKS4NCihBIHJpZ2h0IFBJVEEgZm9yIGVtYmVk
ZGVkIHN5c3RlbXMgd2hlcmUgb25seSBwcmludGYoKSBleGlzdHMuKQ0KDQoJRGF2aWQNCg0K
