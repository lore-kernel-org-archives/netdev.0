From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Sun, 31 Mar 2013 01:18:12 +0000
Message-ID: <157393863283F442885425D2C45428564F202477@nasanexd02f.na.qualcomm.com>
References: <CDAFEDABF718A54BABD0DA5476695307475CCD42@SHEXMB-01.global.atheros.com>
	 <20100125.163612.582489483209420341.anders@netinsight.net>
	 <CDAFEDABF718A54BABD0DA5476695307475CCFF8@SHEXMB-01.global.atheros.com>
	 <20100126.093439.651115405791675606.anders@netinsight.net>
 <1364689558.3557.22.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"565404@bugs.debian.org" <565404@bugs.debian.org>,
	"Hannes Frederic Sowa (hannes@stressinduktion.org)"
	<hannes@stressinduktion.org>
To: Ben Hutchings <ben@decadent.org.uk>,
	=?utf-8?B?QW5kZXJzIEJvc3Ryw7Zt?= <anders@netinsight.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabertooth02.qualcomm.com ([65.197.215.38]:3587 "EHLO
	sabertooth02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755284Ab3CaBSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 21:18:13 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+ID4NCj4gPiA+IEkndmUgdGVzdGVkIHdpdGgNCj4gPiA+IERlYmlhbiBsaW51eC1pbWFnZS0y
LjYuMjYtMi1hbWQ2NCB2ZXJzaW9uIDIuNi4yNi0xOWxlbm55MiwgRGViaWFuDQo+ID4gPiBsaW51
eC1pbWFnZS0yLjYuMzAtYnBvLjItYW1kNjQgdmVyc2lvbiAyLjYuMzAtOH5icG81MCsyIGFuZA0K
PiA+ID4ga2VybmVsLm9yZw0KPiA+ID4gMi42LjMwLjEwIGFtZDY0IHdpdGggZXRodG9vbCBwYXRj
aCBmb3Igc2V0dGluZyBvZiB0c28uIFNhbWUgcmVzdWx0Lg0KPiA+DQo+ID4gRG9lcyBib290aW5n
IHdpdGggdGhlIGtlcm5lbCBwYXJhbWV0ZXIgJ3BjaT1ub21zaScgYXZvaWQgdGhlIHByb2JsZW0/
DQo+ID4NCj4gDQo+IEhhbm5lcyBoYXMgZm91bmQgRE1BLXdyaXRlIChmb3IgcngtcGFja2V0KSAg
aXMgYWJub3JtYWwgZHVlIHRvIG1zaSBmdW5jdGlvbi4NCj4gQnV0IFRTTyBpcyBmb3IgcngtcGFj
a2V0LCBhbiBvcHBvc2l0ZSBkaXJlY3Rpb24uIEknbSBub3Qgc3VyZSA6KCwgSWYgc29tZW9uZQ0K
PiBoYXMgdGhpcyBpc3N1ZSwgIGhlL3NoZSBjb3VsZCBoYXZlIGEgdHJ5Lg0KPiANCg0KSSBjaGVj
a2VkIHdpbmRvd3MgZHJpdmVyLCBpdCBkb2VzIGxpbWl0ICB0aGUgbWF4IHBhY2tldCBsZW5ndGgg
Zm9yIFRTTw0Kd2luZG93cyBYUCA6IDMyKjEwMjQgYnl0ZXMgKGluY2x1ZGUgTUFDIGhlYWRlciBh
bmQgYWxsIE1BQyBwYXlsb2FkKS4gTm8gc3VwcG9ydCBJUC9UQ1Agb3B0aW9uLg0KV2luZG93cyA3
OiAgMTUsIDAwMCBieXRlcywgc3VwcG9ydCBJUC9UQ1Agb3B0aW9uLg0KDQpUaGFua3MNClhpb25n
DQoNCg==
