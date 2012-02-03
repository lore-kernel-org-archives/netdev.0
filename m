From: Satoru Moriya <satoru.moriya@hds.com>
Subject: RE: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Fri, 3 Feb 2012 15:31:48 -0500
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA36@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
	 <02e98f84ee62073e1bf92338f6744fde@localhost>
 <1327502660.2425.60.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usindpps06.hds.com ([207.126.252.19]:43562 "EHLO
	usindpps06.hds.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756754Ab2BCUcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 15:32:23 -0500
In-Reply-To: <1327502660.2425.60.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gMDEvMjUvMjAxMiAwOTo0NCBBTSwgRXJpYyBEdW1hemV0IHdyb3RlOg0KPiBBZ3JlZWQsIGJ1
dCBsYXN0IHRpbWUgSSB0cmllZCBzeXN0ZW10YXAgSSBmYWlsZWQgbWlzZXJhYmx5Lg0KPiBJdCB3
YXMgb24gYSBkZWJpYW4gZGlzdHJvLg0KPiANCj4gQW55d2F5LCBpdCBzZWVtcyB3ZSBsYWNrIGEg
TElOVVhfTUlCX1RDUFJFVFJBTlNGQUlMIGNvdW50ZXIuDQo+IA0KPiAibmV0c3RhdCAtcyIgaXMg
YW4gaW5jcmVkaWJsZSB1bml2ZXJzYWwgdG9vbC4NCj4gDQo+IFtQQVRDSCBuZXQtbmV4dF0gdGNw
OiBhZGQgTElOVVhfTUlCX1RDUFJFVFJBTlNGQUlMIGNvdW50ZXINCj4gDQo+IEl0IG1pZ2h0IGJl
IHVzZWZ1bCB0byBnZXQgYSBjb3VudGVyIG9mIGZhaWxlZCB0Y3BfcmV0cmFuc21pdF9za2IoKSAN
Cj4gY2FsbHMuDQoNClRoYW5rIHlvdSwgRXJpYy4NCg0KVGhpcyBpcyBhIGdvb2QgZmlyc3Qgc3Rl
cCBmb3IgdXMgdG8gZ3JhYiB0aGUgZmFpbHVyZSBvZg0KcmV0cmFuc21pc3Npb24uIEJ1dCB1bmZv
cnR1bmF0ZWx5LCBpdCdzIG5vdCBlbm91Z2ggYmVjYXVzZQ0Kd2hlbiB3ZSBhbmFseXplIGluY2lk
ZW50cyBhbmQgcmVwb3J0IHRvIG91ciBjdXN0b21lcnMsDQp3ZSBuZWVkIG1vcmUgZGV0YWlsZWQg
aW5mb3JtYXRpb24gc3VjaCBhcyB3aGVuIGl0IGhhcHBlbmVkLA0Kd2h5IGl0IGZhaWxlZCBldGMu
DQoNClRoZXJlZm9yZSBJIHByb3Bvc2VkIHRoaXMgdHJhY2Vwb2ludC4NCg0KUmVnYXJkcywNClNh
dG9ydQ0K
