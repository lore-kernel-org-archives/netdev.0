From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: RE: [Pv-drivers] [PATCH net-next] vmxnet3: set netdev parant device
 before calling netdev_info
Date: Wed, 20 Jul 2011 21:05:46 -0700
Message-ID: <0975FDF228005340AA9C93B7681E5E8B13818C32F1@exch-mbx-112.vmware.com>
References: <alpine.LRH.2.00.1107201834220.19334@sbhatewara-dev1.eng.vmware.com>
	 <03E840D17E263A48A5766AD576E0423A03C5836359@exch-mbx-111.vmware.com>
 <1311220141.1663.24.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>
To: Joe Perches <joe@perches.com>, Scott Goldman <scottjg@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:45699 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750704Ab1GUEF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 00:05:58 -0400
In-Reply-To: <1311220141.1663.24.camel@Joe-Laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBKb2UgUGVyY2hlcyBbbWFpbHRv
OmpvZUBwZXJjaGVzLmNvbV0NCj4gU2VudDogV2VkbmVzZGF5LCBKdWx5IDIwLCAyMDExIDg6NDkg
UE0NCj4gVG86IFNjb3R0IEdvbGRtYW4NCj4gQ2M6IFNocmV5YXMgQmhhdGV3YXJhOyBuZXRkZXZA
dmdlci5rZXJuZWwub3JnOyBwdi1kcml2ZXJzQHZtd2FyZS5jb20NCj4gU3ViamVjdDogUkU6IFtQ
di1kcml2ZXJzXSBbUEFUQ0ggbmV0LW5leHRdIHZteG5ldDM6IHNldCBuZXRkZXYgcGFyYW50DQo+
IGRldmljZSBiZWZvcmUgY2FsbGluZyBuZXRkZXZfaW5mbw0KPiANCj4gT24gV2VkLCAyMDExLTA3
LTIwIGF0IDIwOjA2IC0wNzAwLCBTY290dCBHb2xkbWFuIHdyb3RlOg0KPiA+ID4gUGFyZW50IGRl
dmljZSBmb3IgbmV0ZGV2IHNob3VsZCBiZSBzZXQgYmVmb3JlIG5ldGRldl9pbmZvKCkgY2FuIGJl
DQo+IGNhbGxlZA0KPiA+ID4gb3RoZXJ3aXNlIHRoZXJlIGlzIGEgTlVMTCBwb2ludGVyIGRlcmVm
ZXJlbmNlIGFuZCBwcm9iZSgpIGZhaWxzLg0KPiANCj4gSSBiZWxpZXZlIHRoaXMgaXMgbm90IHRy
dWUuDQo+IEkgZG9uJ3Qgc2VlIGFueSBOVUxMIHBvaW50ZXIgZGVyZWZlcmVuY2UgaGVyZS4NCj4g
ZnVuY3Rpb25zIGFuZCBtYWNyb3MgcmVvcmRlcmVkIHRvcCB0byBib3R0b20uDQo+IA0KDQoNClRo
YW5rcyBmb3IgbG9va2luZyBKb2UuDQpUaGlzIGhhcHBlbmVkIGluIDIuNi4zNi4gSSBzYXcgdGhl
IHBhbmljIGluIDIuNi4zNCBhbmQgYXNzdW1lZCB0aGF0IGl0IHdvdWxkIGJlIHNhbWUNCmluIHRo
ZSBsYXRlc3Qga2VybmVsLg0KSXQgd291bGQgbm90IHBhbmljIGluIDMuMCBidXQgaXQgaXMgZ29v
ZCB0byBoYXZlIHRoZSBwYXJlbnQgZGV2aWNlIHNldCBlYXJseS4NCg==
