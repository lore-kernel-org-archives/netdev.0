From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] FOU: Fix no return statement warning for
 !CONFIG_NET_FOU_IP_TUNNELS
Date: Thu, 13 Nov 2014 14:32:22 -0500 (EST)
Message-ID: <20141113.143222.391822191941346577.davem@davemloft.net>
References: <8cf12c98c1a9606f2bd69dd9c108d76f444ab79e.1415879256.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, therbert@google.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58633 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934059AbaKMTcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 14:32:31 -0500
In-Reply-To: <8cf12c98c1a9606f2bd69dd9c108d76f444ab79e.1415879256.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVGhvbWFzIEdyYWYgPHRncmFmQHN1dWcuY2g+DQpEYXRlOiBUaHUsIDEzIE5vdiAyMDE0
IDEyOjQ4OjIxICswMTAwDQoNCj4gbmV0L2lwdjQvZm91LmM6IEluIGZ1bmN0aW9uIKFpcF90dW5u
ZWxfZW5jYXBfZGVsX2ZvdV9vcHOiOg0KPiBuZXQvaXB2NC9mb3UuYzo4NjE6MTogd2FybmluZzog
bm8gcmV0dXJuIHN0YXRlbWVudCBpbiBmdW5jdGlvbiByZXR1cm5pbmcgbm9uLXZvaWQgWy1XcmV0
dXJuLXR5cGVdDQo+IA0KPiBGaXhlczogYThjNWY5MGZiNSAoImlwX3R1bm5lbDogT3BzIHJlZ2lz
dHJhdGlvbiBmb3Igc2Vjb25kYXJ5IGVuY2FwIChmb3UsIGd1ZSkiKQ0KPiBTaWduZWQtb2ZmLWJ5
OiBUaG9tYXMgR3JhZiA8dGdyYWZAc3V1Zy5jaD4NCg0KQXBwbGllZCwgdGhhbmtzIFRob21hcy4N
Cg==
