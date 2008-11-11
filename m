From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] ixgbe: Fix usage of netif_*_all_queues() with
	netif_carrier_{off|on}()
Date: Tue, 11 Nov 2008 00:37:37 -0800
Message-ID: <F86E8680A7D9D74A99DC6345E35A69290DF8592E@orsmsx503.amr.corp.intel.com>
References: <20081107221608.13396.10693.stgit@gitlost.lost>
 <49194369.7030902@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Jeff Garzik <jeff@garzik.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28422 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755339AbYKKIhk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 03:37:40 -0500
In-Reply-To: <49194369.7030902@garzik.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBKZWZmIEtpcnNoZXIgd3JvdGU6DQo+PiBGcm9tOiBQSiBXYXNraWV3aWN6IDxwZXRlci5wLndh
c2tpZXdpY3ouanJAaW50ZWwuY29tPg0KPj4NCj4+IG5ldGlmX2NhcnJpZXJfb2ZmKCkgaXMgc3Vm
ZmljaWVudCB0byBzdG9wIFR4IGludG8gdGhlIGRyaXZlci4gIFN0b3BwaW5nIHRoZSBUeA0KPj4g
cXVldWVzIGlzIHJlZHVuZGFudCBhbmQgdW5uZWNlc3NhcnkuICBCeSB0aGUgc2FtZSB0b2tlbiwg
bmV0aWZfY2Fycmllcl9vbigpDQo+PiB3aWxsIGJlIHN1ZmZpY2llbnQgdG8gcmUtZW5hYmxlIFR4
LCBzbyB3YWtpbmcgdGhlIHF1ZXVlcyBpcyB1bm5lY2Vzc2FyeS4NCg0KPiBJcyB0aGlzIGEgZml4
IGFzIHRoZSBzdWJqZWN0IHNheXMgKDIuNi4yOCksIG9yIGFuIG9wdGltaXphdGlvbiBhcyB0aGUN
Cj4gZGVzY3JpcHRpb24gaW1wbGllcyAoMi42LjI5KT8NCg0KPiBBRkFJQ1MgZnJvbSBhIHF1aWNr
IGdsYW5jZSwgdGhpbmdzIGFyZSBub3QgYWN0dWFsbHkgX2Jyb2tlbl8sIGFyZSB0aGV5Pw0KDQo+
ICAgICAgICBKZWZmDQoNClRoaXMgY2FuIGJlIGFwcGxpZWQgdG8gMi42LjI5OyBpdCBkb2Vzbid0
IG5lZWQgMi42LjI4IGluY2x1c2lvbi4gIE5vdGhpbmcgaXMgYnJva2VuIGhlcmUsIGl0J3MganVz
dCBwb29yIHVzYWdlLiAgRGF2ZU0gcG9pbnRlZCB0aGlzIG91dCB0byB1cyBhd2hpbGUgYWdvLCBh
bmQgSSd2ZSBmaW5hbGx5IGdvdHRlbiBhcm91bmQgdG8gZ2V0dGluZyB0aGUgc2ltcGxlIHBhdGNo
IG91dCB0byBjb3JyZWN0IHRoZSB1bm5lZWRlZCBvdmVyaGVhZC4NCg0KQ2hlZXJzLA0KLVBKIFdh
c2tpZXdpY3oNCg==
