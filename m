From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH 07/15] net: i40e calls skb_set_hash
Date: Mon, 13 Jan 2014 21:53:32 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B7312BADC@ORSMSX101.amr.corp.intel.com>
References: <alpine.DEB.2.02.1312172325550.24389@tomh.mtv.corp.google.com>
 <CAL3LdT4M0gHP5bW3A1GDJGy2zrt4+YQpK3i8WhAp31N2yHsQkg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:54527 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752193AbaAMVxe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jan 2014 16:53:34 -0500
In-Reply-To: <CAL3LdT4M0gHP5bW3A1GDJGy2zrt4+YQpK3i8WhAp31N2yHsQkg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBuZXRkZXYtb3duZXJAdmdlci5rZXJuZWwub3JnIFttYWlsdG86bmV0ZGV2LW93bmVy
QHZnZXIua2VybmVsLm9yZ10NCj4gT24gQmVoYWxmIE9mIEplZmYgS2lyc2hlcg0KPiBTZW50OiBX
ZWRuZXNkYXksIERlY2VtYmVyIDE4LCAyMDEzIDEyOjQwIEFNDQo+IFRvOiBUb20gSGVyYmVydA0K
PiBDYzogRGF2aWQgTWlsbGVyOyBuZXRkZXYNCj4gU3ViamVjdDogUmU6IFtQQVRDSCAwNy8xNV0g
bmV0OiBpNDBlIGNhbGxzIHNrYl9zZXRfaGFzaA0KPiANCj4gT24gVHVlLCBEZWMgMTcsIDIwMTMg
YXQgMTE6MjcgUE0sIFRvbSBIZXJiZXJ0IDx0aGVyYmVydEBnb29nbGUuY29tPiB3cm90ZToNCj4g
PiBEcml2ZXJzIHNob3VsZCBjYWxsIHNrYl9zZXRfaGFzaCB0byBzZXQgdGhlIGhhc2ggYW5kIGl0
cyB0eXBlIGluIGFuDQo+ID4gc2tidWZmLg0KPiA+DQo+ID4gU2lnbmVkLW9mZi1ieTogVG9tIEhl
cmJlcnQgPHRoZXJiZXJ0QGdvb2dsZS5jb20+DQo+ID4gLS0tDQo+ID4gIGRyaXZlcnMvbmV0L2V0
aGVybmV0L2ludGVsL2k0MGUvaTQwZV90eHJ4LmMgfCAzICsrLQ0KPiA+ICAxIGZpbGUgY2hhbmdl
ZCwgMiBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9uKC0pDQo+ID4NCj4gDQo+IEkgaGF2ZSBhZGRl
ZCB0aGlzIHBhdGNoIHRvIG15IHF1ZXVlLCB0aGFua3MgVG9tLg0KDQpBbmQgdW5mb3J0dW5hdGVs
eSBpdCBmYWlscyB0byBjb21waWxlIGdpdmluZyB0aGUgZm9sbG93aW5nIGVycm9yOg0KLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tDQpkcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9pNDBlL2k0MGVfdHhyeC5jOiBJ
biBmdW5jdGlvbiAnaTQwZV9jbGVhbl9yeF9pcnEnOg0KZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50
ZWwvaTQwZS9pNDBlX3R4cnguYzoxMDg4OiBlcnJvcjogdG9vIGZldyBhcmd1bWVudHMgdG8gZnVu
Y3Rpb24gJ2k0MGVfcnhfY2hlY2tzdW0nDQo=
