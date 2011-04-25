From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make WARN_ON in dev_disable_lro() useful
Date: Mon, 25 Apr 2011 11:56:40 -0700 (PDT)
Message-ID: <20110425.115640.226782330.davem@davemloft.net>
References: <1303397531.3685.16.camel@edumazet-laptop>
	<20110421224215.9B8AC13909@rere.qmqm.pl>
	<1303449113.13893.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53974
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758810Ab1DYS5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 14:57:14 -0400
In-Reply-To: <1303449113.13893.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPg0KRGF0ZTogRnJpLCAy
MiBBcHIgMjAxMSAwNzoxMTo1MyArMDIwMA0KDQo+IExlIHZlbmRyZWRpIDIyIGF2cmlsIDIwMTEg
w6AgMDA6NDIgKzAyMDAsIE1pY2hhxYIgTWlyb3PFgmF3IGEgw6ljcml0IDoNCj4+IFNpZ25lZC1v
ZmYtYnk6IE1pY2hhxYIgTWlyb3PFgmF3IDxtaXJxLWxpbnV4QHJlcmUucW1xbS5wbD4NCj4+IC0t
LQ0KPj4gIG5ldC9jb3JlL2Rldi5jIHwgICAgMyArKy0NCj4+ICAxIGZpbGVzIGNoYW5nZWQsIDIg
aW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbnMoLSkNCj4+IA0KPj4gZGlmZiAtLWdpdCBhL25ldC9j
b3JlL2Rldi5jIGIvbmV0L2NvcmUvZGV2LmMNCj4+IGluZGV4IDM4NzFiZjYuLjM0MjExODQgMTAw
NjQ0DQo+PiAtLS0gYS9uZXQvY29yZS9kZXYuYw0KPj4gKysrIGIvbmV0L2NvcmUvZGV2LmMNCj4+
IEBAIC0xMzE1LDcgKzEzMTUsOCBAQCB2b2lkIGRldl9kaXNhYmxlX2xybyhzdHJ1Y3QgbmV0X2Rl
dmljZSAqZGV2KQ0KPj4gIAkJcmV0dXJuOw0KPj4gIA0KPj4gIAlfX2V0aHRvb2xfc2V0X2ZsYWdz
KGRldiwgZmxhZ3MgJiB+RVRIX0ZMQUdfTFJPKTsNCj4+IC0JV0FSTl9PTihkZXYtPmZlYXR1cmVz
ICYgTkVUSUZfRl9MUk8pOw0KPj4gKwlpZiAodW5saWtlbHkoZGV2LT5mZWF0dXJlcyAmIE5FVElG
X0ZfTFJPKSkNCj4+ICsJCW5ldGRldl9XQVJOKGRldiwgImZhaWxlZCB0byBkaXNhYmxlIExSTyFc
biIpOw0KPj4gIH0NCj4+ICBFWFBPUlRfU1lNQk9MKGRldl9kaXNhYmxlX2xybyk7DQo+PiAgDQo+
IA0KPiBZZXMsIGFzIHN1Z2dlc3RlZCBvbmUgbW9udGggYWdvDQo+IGh0dHA6Ly9wZXJtYWxpbmsu
Z21hbmUub3JnL2dtYW5lLmxpbnV4Lm5ldHdvcmsvMTg5OTUxDQo+IA0KPiBTaWduZWQtb2ZmLWJ5
OiBFcmljIER1bWF6ZXQgPGVyaWMuZHVtYXpldEBnbWFpbC5jb20+DQoNCkFwcGxpZWQsIHRoYW5r
cy4NCg==
