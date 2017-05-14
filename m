From: Bart Van Assche <Bart.VanAssche@sandisk.com>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Sun, 14 May 2017 19:08:50 +0000
Message-ID: <1494788929.21774.1.camel@sandisk.com>
References: <20170510072627.12060-1-hch@lst.de>
         <1494514662.2489.1.camel@sandisk.com> <20170514055848.GA23149@lst.de>
         <20170514.115116.499149210596634881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>,
        "ubraun@linux.vnet.ibm.com" <ubraun@linux.vnet.ibm.com>
To: "hch@lst.de" <hch@lst.de>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa4.hgst.iphmx.com ([216.71.154.42]:38597 "EHLO
        esa4.hgst.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751451AbdENTIx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 15:08:53 -0400
In-Reply-To: <20170514.115116.499149210596634881.davem@davemloft.net>
Content-Language: en-US
Content-ID: <B9F0FA574049584AAFE91E63EEAAAB11@namprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gU3VuLCAyMDE3LTA1LTE0IGF0IDExOjUxIC0wNDAwLCBEYXZpZCBNaWxsZXIgd3JvdGU6DQo+
IEZyb206IENocmlzdG9waCBIZWxsd2lnIDxoY2hAbHN0LmRlPg0KPiBEYXRlOiBTdW4sIDE0IE1h
eSAyMDE3IDA3OjU4OjQ4ICswMjAwDQo+IA0KPiA+IHRoaXMgcGF0Y2ggaGFzIG5vdCBiZWVuIHN1
cGVyY2VlZGVkIGJ5IGFueXRoaW5nLCBjYW4geW91IGV4cGxhaW4gd2h5DQo+ID4gaXQgaGFzIGJl
ZW4gbWFya2VkIGFzIHN1Y2ggaW4gcGF0Y2h3b3Jrcz8NCj4gDQo+IEkgdGhpbmsgeW91J3JlIGJl
aW5nIG92ZXJiZWFyaW5nIGJ5IHJlcXVpcmluZyB0aGlzIHRvIGJlIG1hcmtlZCBCUk9LRU4NCj4g
YW5kIEkgd291bGQgbGlrZSB5b3UgdG8gZXhwbG9yZSBvdGhlciB3YXlzIHdpdGggdGhlIGF1dGhv
cnMgdG8gZml4DQo+IHdoYXRldmVyIHBlcmNlaXZlZCBwcm9ibGVtcyB5b3UgdGhpbmsgU01DIGhh
cy4NCj4gDQo+IFlvdSBjbGFpbSB0aGF0IHRoaXMgaXMgc29tZWhvdyAidXJnZW50IiBpcyBmYWxz
ZS4gIFlvdSBjYW4gYXNrDQo+IGRpc3RyaWJ1dGlvbnMgdG8gZGlzYWJsZSBTTUMgb3Igd2hhdGV2
ZXIgaW4gdGhlIHNob3J0IHRlcm0gaWYgaXQNCj4gcmVhbGxseSwgdHJ1bHksIGJvdGhlcnMgeW91
Lg0KDQpIZWxsbyBEYXZlLA0KDQpUaGVyZSBpcyBhZ3JlZW1lbnQgdGhhdCB0aGUgdXNlci1zcGFj
ZSBBUEkgZm9yIHVzaW5nIHRoZSBTTUMgcHJvdG9jb2wgbXVzdA0KYmUgY2hhbmdlZCwgbmFtZWx5
IGJ5IGRyb3BwaW5nIEFGX1NNQyBhbmQgYnkgbWFraW5nIGFwcGxpY2F0aW9ucyB1c2UgdGhlDQpT
TUMgcHJvdG9jb2wgdGhyb3VnaCBzb2NrZXQoQUZfSU5FVC4uLiwgU09DS19TVFJFQU0sIC4uLiku
IFdoYXQgaXMgeW91cg0KcGxhbiB0byBhdm9pZCB0aGF0IGFwcGxpY2F0aW9ucyBzdGFydCB1c2lu
ZyBhbmQgZGVwZW5kaW5nIG9uIEFGX1NNQz8NCg0KVGhhbmtzLA0KDQpCYXJ0Lg==
