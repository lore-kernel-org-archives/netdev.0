From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] i825xx: znet: fix compiler warnings when building a
 64-bit kernel
Date: Wed, 19 Sep 2012 15:45:55 -0400 (EDT)
Message-ID: <20120919.154555.871732031435066325.davem@davemloft.net>
References: <1347618828-3136-1-git-send-email-mika.westerberg@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: mika.westerberg@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044Ab2ISTp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 15:45:57 -0400
In-Reply-To: <1347618828-3136-1-git-send-email-mika.westerberg@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTWlrYSBXZXN0ZXJiZXJnIDxtaWthLndlc3RlcmJlcmdAbGludXguaW50ZWwuY29tPg0K
RGF0ZTogRnJpLCAxNCBTZXAgMjAxMiAxMzozMzo0OCArMDMwMA0KDQo+IFdoZW4gYnVpbGRpbmcg
NjQtYml0IGtlcm5lbCB3aXRoIHRoaXMgZHJpdmVyIHdlIGdldCBmb2xsb3dpbmcgd2FybmluZ3Mg
ZnJvbQ0KPiB0aGUgY29tcGlsZXI6DQo+IA0KPiBkcml2ZXJzL25ldC9ldGhlcm5ldC9pODI1eHgv
em5ldC5jOiBJbiBmdW5jdGlvbiChaGFyZHdhcmVfaW5pdKI6DQo+IGRyaXZlcnMvbmV0L2V0aGVy
bmV0L2k4MjV4eC96bmV0LmM6ODYzOjI5OiB3YXJuaW5nOiBjYXN0IGZyb20gcG9pbnRlciB0byBp
bnRlZ2VyIG9mIGRpZmZlcmVudCBzaXplIFstV3BvaW50ZXItdG8taW50LWNhc3RdDQo+IGRyaXZl
cnMvbmV0L2V0aGVybmV0L2k4MjV4eC96bmV0LmM6ODcwOjI5OiB3YXJuaW5nOiBjYXN0IGZyb20g
cG9pbnRlciB0byBpbnRlZ2VyIG9mIGRpZmZlcmVudCBzaXplIFstV3BvaW50ZXItdG8taW50LWNh
c3RdDQo+IA0KPiBGaXggdGhlc2UgYnkgY2FsbGluZyBpc2FfdmlydF90b19idXMoKSBiZWZvcmUg
cGFzc2luZyB0aGUgcG9pbnRlcnMgdG8NCj4gc2V0X2RtYV9hZGRyKCkuDQo+IA0KPiBTaWduZWQt
b2ZmLWJ5OiBNaWthIFdlc3RlcmJlcmcgPG1pa2Eud2VzdGVyYmVyZ0BsaW51eC5pbnRlbC5jb20+
DQoNClllYWggSSd2ZSBiZWVuIHNlZWluZyB0aGlzIHRvby4NCg0KQXBwbGllZCB0byBuZXQtbmV4
dCwgdGhhbmtzIE1pa2EuDQo=
