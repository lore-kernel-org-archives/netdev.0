From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Thu, 7 Sep 2017 21:30:26 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B1B424@CHN-SV-EXMX02.mchp-main.com>
References: <1500325749-8382-1-git-send-email-festevam@gmail.com>
 <6f984a9c-e6d3-fd0a-6719-fa9032d43d1d@cogentembedded.com>
 <CAOMZO5ABD9iasv67ehcpTzcjU-iD9=8vQ2vM7Gwc4-v9pnUt-Q@mail.gmail.com>
 <f4cdcb4b-feac-5106-8068-e694dbd3b4e6@cogentembedded.com>
 <CAOMZO5BycGHNocULcScDczRoEvbQqjnRZTDrNAw7=+zpadSOSA@mail.gmail.com>
 <20170718133209.GB32757@lunn.ch>
 <CACRpkdYw5GWv3HRCqnWjDfctLEfzcoFdJ7ib_NVKRgw0+Y9dEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <festevam@gmail.com>, <sergei.shtylyov@cogentembedded.com>,
        <davem@davemloft.net>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <fabio.estevam@nxp.com>
To: <linus.walleij@linaro.org>, <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa3.microchip.iphmx.com ([68.232.153.233]:33237 "EHLO
        esa3.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752708AbdIGVar (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 17:30:47 -0400
In-Reply-To: <CACRpkdYw5GWv3HRCqnWjDfctLEfzcoFdJ7ib_NVKRgw0+Y9dEg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBJZiBzb21lb25lIGlzIHVzaW5nIEdQSU8gZGVzY3JpcHRvcnMgd2l0aCBHUElPIGRpc2FibGVk
LCBpLmUuIGNhbGxpbmcNCj4gZ3Bpb2RfZ2V0KCkgYW5kIGZyaWVuZHMsIHRoaXMgaXMgdmVyeSBs
aWtlbHkgdG8gYmUgYSBidWcsIGFuZCB3aGF0DQo+IHRoZSBkcml2ZXIgd2FudHMgdG8gZG8gaXM6
DQo+IA0KPiAgZGVwZW5kcyBvbiBHUElPTElCDQo+IA0KPiBvcg0KPiANCj4gIHNlbGVjdCBHUElP
TElCDQo+IA0KPiBpbiBLY29uZmlnLiBUaGUgd2hvbGUgb3B0aW9uYWwgdGhpbmcgaXMgbWFpbmx5
IGEgbGVmdG92ZXIgZnJvbSB3aGVuIGl0DQo+IHdhcyBwb3NzaWJsZSB0byBoYXZlIGEgbG9jYWwg
aW1wbGVtZW50YXRpb24gb2YgdGhlIEdQSU9MSUIgQVBJIGluDQo+IHNvbWUgY3VzdG9tIGhlYWRl
ciBmaWxlLCBub29uZSBzYW5lIHNob3VsZCBiZSBkb2luZyB0aGF0IGFueW1vcmUsDQo+IGFuZCBp
ZiB0aGV5IGRvLCB0aGV5IGNhbiB2ZXJ5IHdlbGwgZmFjZSB0aGUgd2FybmluZ3MuDQo+IA0KPiBJ
ZiBzb21lb25lIGlzIGZhY2luZyBhIGxvdCBvZiBXQVJOX09OKCkgbWVzc2FnZXMgdG8gdGhpcywg
aXQgaXMgYSBjbGVhcg0KPiBpbmRpY2F0aW9uIHRoYXQgdGhleSBuZWVkIHRvIGZpeCB0aGVpciBL
Y29uZmlnIGFuZCBpbiB0aGF0IGNhc2UgaXQgaXMgcHJvcGVyLg0KTGludXMgJiBBbmRyZXcsDQoN
Ckkga25ldyB0aGF0IGl0IGlzIGFscmVhZHkgaW4gRGF2aWQncyBwdWxsaW5nIHJlcXVlc3QuDQpD
b25maWd1cmluZyBHUElPTElCIGlzIHRoZSByaWdodCBzb2x1dGlvbiAgZXZlbiBpZiBwbGF0Zm9y
bSBkb2Vzbid0IHVzZSBpdD8NCg0KRGlkIEkgbWlzcyBhbnkgbmV3IHBhdGNoPw0KDQpUaGFua3Mu
DQpXb29qdW5nDQo=
