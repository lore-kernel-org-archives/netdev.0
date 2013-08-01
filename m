From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 1/2] net: fix a compile error when
 CONFIG_NET_LL_RX_POLL is not set
Date: Thu, 01 Aug 2013 15:12:07 -0700 (PDT)
Message-ID: <20130801.151207.1619353068833976582.davem@davemloft.net>
References: <1375326625-21427-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, eliezer.tamir@linux.intel.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756855Ab3HAWMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 18:12:08 -0400
In-Reply-To: <1375326625-21427-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQ29uZyBXYW5nIDxhbXdhbmdAcmVkaGF0LmNvbT4NCkRhdGU6IFRodSwgIDEgQXVnIDIw
MTMgMTE6MTA6MjQgKzA4MDANCg0KPiBGcm9tOiBDb25nIFdhbmcgPGFtd2FuZ0ByZWRoYXQuY29t
Pg0KPiANCj4gV2hlbiBDT05GSUdfTkVUX0xMX1JYX1BPTEwgaXMgbm90IHNldCwgSSBnb3Q6DQo+
IA0KPiBuZXQvc29ja2V0LmM6IEluIGZ1bmN0aW9uIKFzb2NrX3BvbGyiOg0KPiBuZXQvc29ja2V0
LmM6MTE2NTo0OiBlcnJvcjogaW1wbGljaXQgZGVjbGFyYXRpb24gb2YgZnVuY3Rpb24goXNrX2J1
c3lfbG9vcKIgWy1XZXJyb3I9aW1wbGljaXQtZnVuY3Rpb24tZGVjbGFyYXRpb25dDQo+IA0KPiBG
aXggdGhpcyBieSBhZGRpbmcgYSBub3Agd2hlbiAhQ09ORklHX05FVF9MTF9SWF9QT0xMLg0KPiAN
Cj4gQ2M6IEVsaWV6ZXIgVGFtaXIgPGVsaWV6ZXIudGFtaXJAbGludXguaW50ZWwuY29tPg0KPiBD
YzogRGF2aWQgUy4gTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KPiBTaWduZWQtb2ZmLWJ5
OiBDb25nIFdhbmcgPGFtd2FuZ0ByZWRoYXQuY29tPg0KDQpBcHBsaWVkIHRvIG5ldA0K
