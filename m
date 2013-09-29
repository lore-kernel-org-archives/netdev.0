From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH net-next] net: skb_is_gso_v6() requires skb_is_gso()
Date: Sun, 29 Sep 2013 09:03:12 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F20DC079B@SJEXCHMB06.corp.ad.broadcom.com>
References: <1380442892.3596.22.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: base64
Cc: netdev <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3106 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753564Ab3I2JD0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Sep 2013 05:03:26 -0400
In-Reply-To: <1380442892.3596.22.camel@edumazet-glaptop.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBuZXRkZXYtb3duZXJAdmdlci5r
ZXJuZWwub3JnIFttYWlsdG86bmV0ZGV2LQ0KPiBvd25lckB2Z2VyLmtlcm5lbC5vcmddIE9uIEJl
aGFsZiBPZiBFcmljIER1bWF6ZXQNCj4gU2VudDogU3VuZGF5LCBTZXB0ZW1iZXIgMjksIDIwMTMg
MTE6MjIgQU0NCj4gVG86IERhdmlkIE1pbGxlcg0KPiBDYzogbmV0ZGV2OyBFaWxvbiBHcmVlbnN0
ZWluDQo+IFN1YmplY3Q6IFtQQVRDSCBuZXQtbmV4dF0gbmV0OiBza2JfaXNfZ3NvX3Y2KCkgcmVx
dWlyZXMgc2tiX2lzX2dzbygpDQo+IA0KPiBGcm9tOiBFcmljIER1bWF6ZXQgPGVkdW1hemV0QGdv
b2dsZS5jb20+DQo+IA0KPiBibngyeCBtYWtlcyBhIGRhbmdlcm91cyB1c2Ugb2Ygc2tiX2lzX2dz
b192NigpLg0KPiANCj4gSXQgc2hvdWxkIGZpcnN0IG1ha2Ugc3VyZSBza2IgaXMgYSBnc28gcGFj
a2V0DQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBFcmljIER1bWF6ZXQgPGVkdW1hemV0QGdvb2dsZS5j
b20+DQo+IENjOiBFaWxvbiBHcmVlbnN0ZWluIDxlaWxvbmdAYnJvYWRjb20uY29tPg0KDQpUaGFu
a3MsIEVyaWMhDQoNCkFja2VkLWJ5OiBEbWl0cnkgS3JhdmtvdiA8ZG1pdHJ5QGJyb2FkY29tLmNv
bT4NCg==
