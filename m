From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net, vxlan Fix compile warning
Date: Mon, 16 Sep 2013 21:23:58 -0400 (EDT)
Message-ID: <20130916.212358.1356743853860170770.davem@davemloft.net>
References: <1379075352-20051-1-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, jpirko@redhat.com, tgraf@redhat.com
To: prarit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822Ab3IQBYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 21:24:05 -0400
In-Reply-To: <1379075352-20051-1-git-send-email-prarit@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogUHJhcml0IEJoYXJnYXZhIDxwcmFyaXRAcmVkaGF0LmNvbT4NCkRhdGU6IEZyaSwgMTMg
U2VwIDIwMTMgMDg6Mjk6MTIgLTA0MDANCg0KPiBGaXggYSB1bmludGlhbGl6ZWQgdmFyaWFibGUg
d2FybmluZy4NCj4gDQo+IGRyaXZlcnMvbmV0L3Z4bGFuLmM6IEluIGZ1bmN0aW9uIKF2eGxhbl9z
b2NrX2FkZKI6DQo+IGRyaXZlcnMvbmV0L3Z4bGFuLmM6MjI0MDoxMTogZXJyb3I6IKFzb2NroiBt
YXkgYmUgdXNlZCB1bmluaXRpYWxpemVkIGluIHRoaXMgZnVuY3Rpb24gWy1XZXJyb3I9bWF5YmUt
dW5pbml0aWFsaXplZF0NCj4gICB2cy0+c29jayA9IHNvY2s7DQo+ICAgICAgICAgICAgXg0KPiBk
cml2ZXJzL25ldC92eGxhbi5jOjIyMTc6MTc6IG5vdGU6IKFzb2NroiB3YXMgZGVjbGFyZWQgaGVy
ZQ0KPiAgIHN0cnVjdCBzb2NrZXQgKnNvY2s7DQo+ICAgICAgICAgICAgICAgICAgXg0KPiANCj4g
U2lnbmVkLW9mZi1ieTogUHJhcml0IEJoYXJnYXZhIDxwcmFyaXRAcmVkaGF0LmNvbT4NCg0KTWFr
ZSBjcmVhdGVfdns0LDZ9X3NvY2soKSByZXR1cm4gYW4gZXJyIHBvaW50ZXIuDQoNClByb2JsZW0g
c29sdmVkIGFuZCBubyBpbmNyZWRpYmx5IHVnbHksIHVubmVjZXNzYXJ5LCBhbm5vdGF0aW9ucy4N
Cg0KVGhlIGVycm9yIGNvZGUgcmV0dXJuIGZyb20gdGhlc2UgZnVuY3Rpb25zIGFscmVhZHkgZ2V0
cyB0dXJuZWQgaW50bw0KYW5kIGVycm9yIHBvaW50ZXIgYXQgdGhlIGNhbGwgc2l0ZSwgd2hpY2gg
bWFrZXMgdGhpcyBzaXR1YXRpb24gZXZlbg0KbW9yZSByZWRpY3Vsb3VzLg0KDQo=
