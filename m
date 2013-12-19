From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Add support for Virtual Receive Side
 Scaling (vRSS)
Date: Thu, 19 Dec 2013 19:21:31 +0000
Message-ID: <6ee28c6a94e74c958ee96c3547741fb9@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1387405262-18334-1-git-send-email-haiyangz@microsoft.com>
 <1387475178.1876.29.camel@bwh-desktop.uk.level5networks.com>
 <ff7f7541d0164d408b3a4278569c593a@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <52B33EC1.5040901@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52B33EC1.5040901@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogRGFuaWVsIEJvcmttYW5u
IFttYWlsdG86ZGJvcmttYW5AcmVkaGF0LmNvbV0NCj4gU2VudDogVGh1cnNkYXksIERlY2VtYmVy
IDE5LCAyMDEzIDE6NDUgUE0NCj4gVG86IEhhaXlhbmcgWmhhbmcNCj4gQ2M6IEJlbiBIdXRjaGlu
Z3M7IGRhdmVtQGRhdmVtbG9mdC5uZXQ7IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IEtZDQo+IFNy
aW5pdmFzYW47IG9sYWZAYWVwZmxlLmRlOyBqYXNvd2FuZ0ByZWRoYXQuY29tOyBsaW51eC0NCj4g
a2VybmVsQHZnZXIua2VybmVsLm9yZzsgZHJpdmVyZGV2LWRldmVsQGxpbnV4ZHJpdmVycHJvamVj
dC5vcmcNCj4gU3ViamVjdDogUmU6IFtQQVRDSCBuZXQtbmV4dF0gaHlwZXJ2OiBBZGQgc3VwcG9y
dCBmb3IgVmlydHVhbCBSZWNlaXZlIFNpZGUNCj4gU2NhbGluZyAodlJTUykNCj4gDQo+IE9uIDEy
LzE5LzIwMTMgMDc6MzYgUE0sIEhhaXlhbmcgWmhhbmcgd3JvdGU6DQo+IA0KPiA+IFRoYW5rIHlv
dSBmb3IgdGhlIHN1Z2dlc3Rpb25zISBJIHdpbGwgcmUtd3JpdGUgdGhlIHNlbmQgcXVldWUNCj4g
PiBzZWxlY3Rpb24sIGVuaGFuY2UgdGhlIGhhc2ggY2FsY3VsYXRpb24sIGFsc28gZml4IHRoZSBp
bml0aWFsaXphdGlvbiBzZXF1ZW5jZS4NCj4gDQo+IEJ0dywgVG9lcGxpdHogaGFzaCBmdW5jdGlv
biBzaG91bGQgZWl0aGVyIGdvIGludG8gbGliL2hhc2guYyBhcyB3ZWxsIG9yDQo+IGluY2x1ZGUv
bGludXgvaGFzaC5oIHRvIGF2b2lkIGVuZGluZyB1cCB3LyB2YXJpb3VzIGltcGxlbWVudGF0aW9u
cyBpbiBtdWx0aXBsZQ0KPiBwbGFjZXMuDQoNCldpbGwgZG8uIA0KDQpUaGFua3MsDQotIEhhaXlh
bmcNCg==
