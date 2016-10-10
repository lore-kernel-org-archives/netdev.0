From: "Chopra, Manish" <Manish.Chopra@cavium.com>
Subject: RE: Accelerated receive flow steering (aRFS) for UDP
Date: Mon, 10 Oct 2016 19:41:23 +0000
Message-ID: <SN1PR07MB2447A415C40779EA488C1DA389DB0@SN1PR07MB2447.namprd07.prod.outlook.com>
References: <SN1PR07MB244706470867A923CF0FAF6589C60@SN1PR07MB2447.namprd07.prod.outlook.com>
         <1475883496.28155.270.camel@edumazet-glaptop3.roam.corp.google.com>
         <SN1PR07MB2447ED02140770F0B46967D589D90@SN1PR07MB2447.namprd07.prod.outlook.com>
         <1476033293.28155.273.camel@edumazet-glaptop3.roam.corp.google.com>
         <SN1PR07MB2447D70FD02730AFCEA410A089D80@SN1PR07MB2447.namprd07.prod.outlook.com>
         <1476052402.28155.277.camel@edumazet-glaptop3.roam.corp.google.com>
         <ed0f723c-5e66-6d23-086d-71744570700a@hpe.com>
         <844f9891-3b30-e5fa-720e-d20e4ea5d751@hpe.com>
 <1476119297.5650.0.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "maorg@mellanox.com" <maorg@mellanox.com>,
        "tom@herbertland.com" <tom@herbertland.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0060.outbound.protection.outlook.com ([104.47.33.60]:36201
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752237AbcJJWOu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Oct 2016 18:14:50 -0400
In-Reply-To: <1476119297.5650.0.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBFcmljIER1bWF6ZXQgW21haWx0
bzplcmljLmR1bWF6ZXRAZ21haWwuY29tXQ0KPiBTZW50OiBNb25kYXksIE9jdG9iZXIgMTAsIDIw
MTYgMTA6MzggUE0NCj4gVG86IFJpY2sgSm9uZXMgPHJpY2suam9uZXMyQGhwZS5jb20+DQo+IENj
OiBDaG9wcmEsIE1hbmlzaCA8TWFuaXNoLkNob3ByYUBjYXZpdW0uY29tPjsgbmV0ZGV2QHZnZXIu
a2VybmVsLm9yZzsNCj4gbWFvcmdAbWVsbGFub3guY29tOyB0b21AaGVyYmVydGxhbmQuY29tDQo+
IFN1YmplY3Q6IFJlOiBBY2NlbGVyYXRlZCByZWNlaXZlIGZsb3cgc3RlZXJpbmcgKGFSRlMpIGZv
ciBVRFANCj4gDQo+IE9uIE1vbiwgMjAxNi0xMC0xMCBhdCAwOToyMyAtMDcwMCwgUmljayBKb25l
cyB3cm90ZToNCj4gPiBPbiAxMC8xMC8yMDE2IDA5OjA4IEFNLCBSaWNrIEpvbmVzIHdyb3RlOg0K
PiA+ID4gT24gMTAvMDkvMjAxNiAwMzozMyBQTSwgRXJpYyBEdW1hemV0IHdyb3RlOg0KPiA+ID4+
IE9LLCBJIGFtIGFkZGluZy9DQyBSaWNrIEpvbmVzLCBuZXRwZXJmIGF1dGhvciwgc2luY2UgaXQg
c2VlbXMgYSBuZXRwZXJmDQo+ID4gPj4gYnVnLCBub3QgYSBrZXJuZWwgb25lLg0KPiA+ID4+DQo+
ID4gPj4gSSBiZWxpZXZlIEkgYWxyZWFkeSBtZW50aW9uZWQgZmFjdCB0aGF0ICJVRFBfU1RSRUFN
IC0tIC1OIiB3YXMgbm90IGRvaW5nDQo+ID4gPj4gYSBjb25uZWN0KCkgb24gdGhlIHJlY2VpdmVy
IHNpZGUuDQo+ID4gPg0KPiA+ID4gSSBjYW4gY29uZmlybSB0aGF0IHRoZSByZWNlaXZlIHNpZGUg
b2YgdGhlIG5ldHBlcmYgb21uaSBwYXRoIGlzbid0DQo+ID4gPiB0cnlpbmcgdG8gY29ubmVjdCBV
RFAgZGF0YWdyYW1zLiAgSSB3aWxsIHNlZSB3aGF0IEkgY2FuIHB1dCB0b2dldGhlci4NCj4gPg0K
PiA+IEkndmUgcHV0IHNvbWV0aGluZyB0b2dldGhlciBhbmQgcHVzaGVkIGl0IHRvIHRoZSBuZXRw
ZXJmIHRvcCBvZiB0cnVuay4NCj4gPiBJdCBzZWVtcyB0byBoYXZlIGJlZW4gc3VjY2Vzc2Z1bCBv
biBhIHF1aWNrIGxvb3BiYWNrIFVEUF9TVFJFQU0gdGVzdC4NCj4gDQo+IEluZGVlZCwgaXQgbG9v
a3MgYmV0dGVyLCB0aGFua3MgIQ0KPiANCg0KVGhhbmtzIEVyaWMgYW5kIFJpY2suICBXaXRoIHRo
aXMsIHByb2JsZW0gZ290IHJlc29sdmVkIG5vdy4NCkkgZG8gc2VlIGZsb3dzIGdldHRpbmcgc3Rl
ZXJlZCBmb3IgVURQIHBhY2tldHMgbm93IDotKQ0K
