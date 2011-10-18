From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: RE: [PATCH 6/7] mlx4_en: Adding rxhash support
Date: Tue, 18 Oct 2011 07:36:21 +0000
Message-ID: <953B660C027164448AE903364AC447D2235EEB65@MTLDAG01.mtl.com>
References: <4E9C8D8B.90606@mellanox.co.il>
 <1318902525.2571.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:47275 "HELO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753473Ab1JRHkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 03:40:07 -0400
In-Reply-To: <1318902525.2571.24.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+ICAJcnNzX2NvbnRleHQtPmZsYWdzID0gcnNzX21hc2s7DQo+ID4gKwlyc3NfY29udGV4dC0+
aGFzaF9mbiA9IDE7DQo+ID4gKwlmb3IgKGkgPSAwOyBpIDwgMTA7IGkrKykNCj4gPiArCQlyc3Nf
Y29udGV4dC0+cnNzX2tleVtpXSA9IHJhbmRvbTMyKCk7DQo+ID4NCj4gDQo+IFRoYXRzIGJpdCBv
ZiBhIHByb2JsZW0gOiBUd28gTklDUyB3aWxsIGhhdmUgZGlmZmVyZW50IHNlZWRzLCBhbmQgdGh1
cyBwcm92aWRlIGRpZmZlcmVudCByeGhhc2ggZm9yIGEgZ2l2ZW4gZmxvdy4gQSBib25kaW5nIG9m
IHR3byBOSUNTIHdpbGwNCj4gbm90IGJlIGFibGUgdG8gcHJvdmlkZSBhIGNvbnNpc3RlbnQgcnho
YXNoLg0KPiANCj4gZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaWdiL2lnYl9tYWluLmMgdXNl
cyBhIHN0YXRpYyB0YWJsZSB0byBhdm9pZCB0aGlzIHByb2JsZW0uDQo+IA0KDQpIZWxsbyBFcmlj
LCB0aGFua3MgZm9yIHlvdXIgcmV2aWV3Lg0KDQpJIGFncmVlIHRoYXQgaW4gdGhpcyBjYXNlIHR3
byBwb3J0cyB3aWxsIGhhdmUgZGlmZmVyZW50IHNlZWRzLg0KQnV0IGV2ZW4gaWYgd2UgdXNlIHN0
YXRpYyB2YWx1ZXMgZm9yIHRoZSBrZXksIHdoYXQgYWJvdXQgYm9uZGluZyBvZiAyIE5JQ3MgZnJv
bSBkaWZmZXJlbnQgdmVuZG9ycz8NCkhvdyBjYW4gd2UgZW5zdXJlIHdlIGdldCBzYW1lIHJ4aGFz
aCB2YWx1ZSBmb3IgYWxsIE5JQ3M/DQoNClRoZXJlIGFyZSBhbHNvIG90aGVyIGRyaXZlcnMgdGhh
dCB1c2UgcmFuZG9tIHZhbHVlcyBhcyB3ZWxsLCBmb3IgZXhhbXBsZToNCmRyaXZlcnMvbmV0L2V0
aGVybmV0L2Jyb2FkY29tL2JueDJ4L2JueDJ4X2Ntbi5jDQoNClRoYW5rcywNCllldmdlbnkNCg0K
