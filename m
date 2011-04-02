From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH] net: ethtool support to configure number of channels
Date: Fri, 1 Apr 2011 21:36:52 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FD10E8D93@MNEXMB2.qlogic.org>
References: <1301652075-382-1-git-send-email-amit.salecha@qlogic.com>
 <1301677824.4679.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe004.messaging.microsoft.com ([216.32.180.14]:10451
	"EHLO VA3EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751082Ab1DBChC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:37:02 -0400
In-Reply-To: <1301677824.4679.10.camel@bwh-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBJJ20gbm90IHN1cmUgd2h5IHlvdSByZWR1Y2VkIHRoaXMgdG8gYSBzaW5nbGUgY291bnQuICBJ
ZiBpZiB0aGUgZHJpdmVyDQo+IG9yIGhhcmR3YXJlIGRvZXNuJ3QgYWxsb3cgY2VydGFpbiBjb21i
aW5hdGlvbnMgb2YgY291bnRzLCBpdCBtaWdodCBiZQ0KPiBuZWNlc3NhcnkgdG8gY29uZmlndXJl
IHNldmVyYWwgdHlwZXMgYXQgdGhlIHNhbWUgdGltZQ0KPg0KPiA+ICsvKiBDaGFubmVsIElEIGlz
IG1hZGUgdXAgb2YgYSB0eXBlICovDQo+ID4gK2VudW0gZXRodG9vbF9jaGFubmVsX2lkIHsNCj4g
PiArICAgRVRIX0NIQU5fVFlQRV9SWCA9IDB4MSwNCj4gPiArICAgRVRIX0NIQU5fVFlQRV9UWCA9
IDB4Mg0KPiA+ICt9Ow0KPiBbLi4uXQ0KPg0KPiBlbnVtIGV0aHRvb2xfY2hhbm5lbF9pZCB3YXMg
bWVhbnQgdG8gYmUgYW4gaWRlbnRpZmllciBvZiBhIHNwZWNpZmljDQo+IGNoYW5uZWwuICBBbiBl
bnVtZXJhdGlvbiBvZiBjaGFubmVsIHR5cGVzIHNob3VsZCBiZSBuYW1lZCBkaWZmZXJlbnRseS4N
Cj4NCg0KSSB3aWxsIG5hbWUgaXQgYXMgZXRodG9vbF9jaGFubmVsX3R5cGUuIEFueSBvdGhlciBz
dWdnZXN0aW9uID8NCg0KPiBUaGlzIGFsc28gb21pdHMgdGhlICdjb21iaW5lZCcgYW5kICdvdGhl
cicgdHlwZXMuICBNb3N0IG11bHRpcXVldWUNCj4gZHJpdmVycyBwYWlyIHVwIFJYIGFuZCBUWCBx
dWV1ZXMgc28gdGhhdCBtb3N0IGNoYW5uZWxzIGNvbWJpbmUgUlggYW5kDQo+IFRYDQo+IHdvcmsu
DQoNCidjb21iaW5lZCcgaXMgb2ssIHdoYXQgaXMgdXNlIG9mICdvdGhlcicgPw0KDQotYW1pdA0K
DQpUaGlzIG1lc3NhZ2UgYW5kIGFueSBhdHRhY2hlZCBkb2N1bWVudHMgY29udGFpbiBpbmZvcm1h
dGlvbiBmcm9tIFFMb2dpYyBDb3Jwb3JhdGlvbiBvciBpdHMgd2hvbGx5LW93bmVkIHN1YnNpZGlh
cmllcyB0aGF0IG1heSBiZSBjb25maWRlbnRpYWwuIElmIHlvdSBhcmUgbm90IHRoZSBpbnRlbmRl
ZCByZWNpcGllbnQsIHlvdSBtYXkgbm90IHJlYWQsIGNvcHksIGRpc3RyaWJ1dGUsIG9yIHVzZSB0
aGlzIGluZm9ybWF0aW9uLiBJZiB5b3UgaGF2ZSByZWNlaXZlZCB0aGlzIHRyYW5zbWlzc2lvbiBp
biBlcnJvciwgcGxlYXNlIG5vdGlmeSB0aGUgc2VuZGVyIGltbWVkaWF0ZWx5IGJ5IHJlcGx5IGUt
bWFpbCBhbmQgdGhlbiBkZWxldGUgdGhpcyBtZXNzYWdlLg0K

