From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: Supporting 4 way connections in LKSCTP
Date: Wed, 4 Dec 2013 16:12:58 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B745E@saturn3.aculab.com>
References: <CAFXGft+CXk3W8=3w=AuYzqYtYnR8nH4Of9=668tUeT+tugD9-A@mail.gmail.com>	<CAFXGftLsKm9a5bmXX4Fe+rnSvYVdBDOyYGwisRP7XMu+ky=DGw@mail.gmail.com>	<CAFXGftLt1p6XpR2eGsMYKjEbbOHvch-LgcFw1sAXThcA2Rtjyw@mail.gmail.com>	<20131127124530.GA23369@hmsreliant.think-freely.org>	<CAFXGftJQV=5Pqs3bhfiS3T1VO1q8jfaMjAUiqm2tDbtSyBCM3A@mail.gmail.com>	<529C9B50.50002@gmail.com>	<CAGugRbXFirQ5P3ek9zN86h4vvO6qsy3eNEooJOApotA+dL+C_g@mail.gmail.com>	<529CB859.9090904@gmail.com>	<CAFXGft+F52p+oaa59=5e5pGfON44N36NA-XMYi5PorzWeybnKw@mail.gmail.com>	<CAFXGft+4o6fT4SYbu3musC+-BEi=xOEGUbZSavF1-0_V1mg6zg@mail.gmail.com>	<529D3BF9.3070208@gmail.com>	<CAFXGftJtCCJ=pVxg_DH-+n2bKmoKXavog0y8mfX+h-1z3hP49Q@mail.gmail.com>	<529DCF42.1070800@gmail.com>	<CAFXGftK5tz90OzObiV7Hi+g080j3zWCNdo217CKdNkOY4JWQUg@mail.gmail.com>	
 <529DF73E.7060604@gmail.com> <CAFXGftKZD0zN1S=UTa_bYr71-v=7mzU=_CewTNkjPv9CGGB_Fg@mail.gmail.com> <529F395B.9040308@gmail.com> <AE90C24D6B3A694183C094C60CF0A2F6026B745D@saturn3.aculab.com> <529F4D1A
	.3050304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>,
	"Karl Heiss" <kheiss@gmail.com>,
	"Neil Horman" <nhorman@tuxdriver.com>,
	<linux-kernel@vger.kernel.org>
To: "Vlad Yasevich" <vyasevich@gmail.com>,
	"Sun Paul" <paulrbk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:60681 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932602Ab3LDQNp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Dec 2013 11:13:45 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20998-07 for <netdev@vger.kernel.org>;
 Wed,  4 Dec 2013 16:13:43 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <529F4D1A.3050304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IFRoZXJlIGFyZSBzb21lIG5ldHdvcmsgY29uZmlndXJhdGlvbnMgdGhhdCBkbyBjYXVzZSBw
cm9ibGVtcy4NCj4gPiBDb25zaWRlciA0IHN5c3RlbXMgd2l0aCAzIExBTiBzZWdtZW50czoNCj4g
PiBBKSAxMC4xMC4xMC4xIG9uIExBTiBYIGFuZCAxOTIuMTY4LjEuMSBvbiBMQU4gWS4NCj4gPiBC
KSAxMC4xMC4xMC4yIG9uIExBTiBYIGFuZCAxOTIuMTY4LjEuMiBvbiBMQU4gWS4NCj4gPiBDKSAx
MC4xMC4xMC4zIG9uIExBTiBYLg0KPiA+IEQpIDEwLjEwLjEwLjQgb24gTEFOIFggYW5kIDE5Mi4x
NjguMS4yIG9uIExBTiBaLg0KPiA+IFRoZXJlIGFyZSBubyByb3V0ZXJzIGJldHdlZW4gdGhlIG5l
dHdvcmtzIChhbmQgbm9uZSBvZiB0aGUgc3lzdGVtcw0KPiA+IGFyZSBydW5uaW5nIElQIGZvcndh
cmRpbmcpLg0KPiA+DQo+ID4gSWYgQSBjb25uZWN0cyB0byBCIGV2ZXJ5dGhpbmcgaXMgZmluZSAt
IHRyYWZmaWMgY2FuIHVzZSBlaXRoZXIgTEFOLg0KPiA+DQo+ID4gQ29ubmVjdGlvbnMgZnJvbSBB
IHRvIEMgYXJlIHByb2JsZW1hdGljIGlmIEMgdHJpZXMgdG8gc2VuZCBhbnl0aGluZw0KPiA+IChl
eGNlcHQgYSBIQikgdG8gMTkyLjE2OC4xLjEgYmVmb3JlIHJlY2VpdmluZyBhIEhCIHJlc3BvbnNl
Lg0KPiA+IE9uZSBvZiB0aGUgU0NUUCBzdGFja3Mgd2UndmUgdXNlZCBkaWQgc2VuZCBtZXNzYWdl
cyB0byBhbg0KPiA+IGluYXBwcm9wcmlhdGUgYWRkcmVzcywgYnV0IEkndmUgZm9yZ290dGVuIHdo
aWNoIG9uZS4NCj4gDQo+IEkgZ3Vlc3MgdGhhdCB3b3VsZCBiZSBwcm9ibGVtYXRpYyBpZiBBIGNh
biBub3QgcmVjZWl2ZSB0cmFmZmljIGZvcg0KPiAxOTIuMTY4LjEuMSBvbiB0aGUgaW50ZXJmYWNl
IGNvbm5lY3RlZCB0byBMQU4gWC4gIEkgc2hvdWxkbid0DQo+IHRlY2huaWNhbGx5IGJlIGEgcHJv
YmxlbSBmb3IgQyBhcyBpdCBzaG91bGQgbWFyayB0aGUgcGF0aCB0byAxOTIuMTY4LjEuMQ0KPiBh
cyBkb3duLiAgRm9yIEEsIGFzIGxvbmcgYXMgaXQgZG9lc24ndCBkZWNpZGUgdG8gQUJPUlQgdGhl
IGFzc29jaWF0aW9uLA0KPiBpdCBzaG91bGRuJ3QgYmUgYSBwcm9ibGVtIGVpdGhlci4gIEl0IHdv
dWxkIGJlIGludGVyZXN0aW5nIHRvIGtub3cgbW9yZQ0KPiBhYm91dCB3aGF0IHByb2JsZW1zIHlv
dSd2ZSBvYnNlcnZlZC4NCg0KSXQgd2FzIGEgbG9uZyB0aW1lIGFnbywgd2UgZG9uJ3QgYWN0dWFs
bHkgZG8gbXVjaCBTQ1RQIHRlc3RpbmcgZXZlbiB0aG91Z2gNCm91ciBwcm9kdWN0IChTUzcgTTNV
QSkgdXNlcyBpdC4gTW9zdGx5IGJlY2F1c2Ugd2UgZG9uJ3Qgd2FudCB0byBmaW5kDQpidWdzIHRo
YXQgYXJlIGhhcmQgdG8gZml4IQ0KDQpXaGF0IHdlIHNhdyB3YXMgQyB1c2luZyB0aGUgMTkyLngg
YWRkcmVzcyAoYXMgc3VwcGxpZWQgaW4gdGhlIElOSVQpIGFuZA0KdGhlc2Ugbm90IGJlaW5nIHJv
dXRhYmxlIHRvIEEgKGFuZCBub3QgZ2V0dGluZyBhIHJlc3BvbnNlIGZyb20gYSAzcmQgc3lzdGVt
KS4NClNvIHRoZSBhcHBsaWNhdGlvbiBsYXllciBpbW1lZGlhdGVseSB0aW1lZCBldmVyeXRoaW5n
IG91dC4NCg0KV2hhdCBJIGNhbid0IHJlbWVtYmVyIGlzIHdoZXRoZXIgdGhpcyB3YXMgTGludXgs
IFNvbGFyaXMgb3IgdGhlIFNDVFAgc3RhY2sNCndlIHRvb2sgZnJvbSBmcmVlYnNkIGFuZCByYW1t
ZWQgaW50byB0aGUgd2luZG93cyBrZXJuZWwuDQoNCglEYXZpZA0KDQo=
