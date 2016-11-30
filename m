From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 3/4] Documentation: net: phy: Add blurb
 about RGMII
Date: Wed, 30 Nov 2016 12:32:04 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB023015E@AcuExch.aculab.com>
References: <20161127184449.12351-1-f.fainelli@gmail.com>
 <20161127184449.12351-4-f.fainelli@gmail.com>
 <583B5D3B.4040108@codeaurora.org>
 <a06d903f-5b80-4683-965f-9a6a1d5fe044@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "sf84@laposte.net" <sf84@laposte.net>,
        "martin.blumenstingl@googlemail.com"
        <martin.blumenstingl@googlemail.com>,
        "mans@mansr.com" <mans@mansr.com>,
        "alexandre.torgue@st.com" <alexandre.torgue@st.com>,
        "peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
        "jbrunet@baylibre.com" <jbrunet@baylibre.com>
To: 'Florian Fainelli' <f.fainelli@gmail.com>,
        Timur Tabi <timur@codeaurora.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.194]:54399 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755746AbcK3McO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 07:32:14 -0500
In-Reply-To: <a06d903f-5b80-4683-965f-9a6a1d5fe044@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRmxvcmlhbiBGYWluZWxsaQ0KPiBTZW50OiAyNyBOb3ZlbWJlciAyMDE2IDIzOjAzDQo+
IExlIDI3LzExLzIwMTYgIDE0OjI0LCBUaW11ciBUYWJpIGEgY3JpdCA6DQo+ID4+ICsgKiBQSFkg
ZGV2aWNlIGRyaXZlcnMgaW4gUEhZTElCIGJlaW5nIHJldXNhYmxlIGJ5IG5hdHVyZSwgYmVpbmcg
YWJsZSB0bw0KPiA+PiArICAgY29uZmlndXJlIGNvcnJlY3RseSBhIHNwZWNpZmllZCBkZWxheSBl
bmFibGVzIG1vcmUgZGVzaWducyB3aXRoDQo+ID4+IHNpbWlsYXIgZGVsYXkNCj4gPj4gKyAgIHJl
cXVpcmVtZW50cyB0byBiZSBvcGVyYXRlIGNvcnJlY3RseQ0KPiA+DQo+ID4gT2ssIHRoaXMgb25l
IEkgZG9uJ3Qga25vdyBob3cgdG8gZml4LiAgSSdtIG5vdCByZWFsbHkgc3VyZSB3aGF0IHlvdSdy
ZQ0KPiA+IHRyeWluZyB0byBzYXkuDQo+IA0KPiBXaGF0IEkgYW0gdHJ5aW5nIHRvIHNheSBpcyB0
aGF0IG9uY2UgYSBQSFkgZHJpdmVyIHByb3Blcmx5IGNvbmZpZ3VyZXMgYQ0KPiBkZWxheSB0aGF0
IHlvdSBoYXZlIHNwZWNpZmllZCwgdGhlcmUgaXMgbm8gcmVhc29uIHdoeSB0aGlzIGlzIG5vdA0K
PiBhcHBsaWNhYmxlIHRvIG90aGVyIHBsYXRmb3JtcyB1c2luZyB0aGlzIHNhbWUgUEhZIGRyaXZl
ci4NCg0KQXMgaGFzIGJlZW4gc3RhdGVkIGVhcmxpZXIgaXQgY2FuIGRlcGVuZCBvbiB0aGUgdHJh
Y2sgbGVuZ3RocyBvbiB0aGUNCmJvYXJkIGl0c2VsZi4NCihBbHRob3VnaCAxbnMgaXMgYWJvdXQg
MSBmb290IC0gc28gdHJhY2sgZGVsYXlzIG9mIHRoYXQgbGVuZ3RoIGFyZSB1bmxpa2VseS4pDQoN
Cj4gPj4gK0NvbW1vbiBwcm9ibGVtcyB3aXRoIFJHTUlJIGRlbGF5IG1pc21hdGNoDQo+ID4+ICsN
Cj4gPj4gKyBXaGVuIHRoZXJlIGlzIGEgUkdNSUkgZGVsYXkgbWlzbWF0Y2ggYmV0d2VlbiB0aGUg
RXRoZXJuZXQgTUFDIGFuZA0KPiA+PiB0aGUgUEhZLCB0aGlzDQo+ID4+ICsgd2lsbCBtb3N0IGxp
a2VseSByZXN1bHQgaW4gdGhlIGNsb2NrIGFuZCBkYXRhIGxpbmUgc2FtcGxpbmcgdG8NCj4gPj4g
Y2FwdHVyZSB1bnN0YWJsZQ0KPiA+DQo+ID4gSSdtIG5vdCBzdXJlIHdoYXQgInNhbXBsaW5nIHRv
IGNhcHR1cmUgdW5zdGFibGUiIGlzIHN1cHBvc2VkIHRvIG1lYW4uDQo+IA0KPiBXaGVuIHRoZSBQ
SFkgZGV2aWNlcyB0YWtlcyBhICJzbmFwc2hvdCIgb2YgdGhlIHN0YXRlIG9mIHRoZSBkYXRhIGxp
bmVzLA0KPiBhZnRlciBhIGNsb2NrIGVkZ2UsIGlmIHRoZSBkZWxheSBpcyBpbXByb3Blcmx5IGNv
bmZpZ3VyZWQsIHRoZXNlIGRhdGENCj4gbGluZXMgYXJlIGdvaW5nIHRvIHN0aWxsIGJlIGZsb2F0
aW5nLCBvciBzaG93IHNvbWUga2luZCBvZg0KPiBjYXBhY2l0YW5jZS9pbmR1Y3RhbmNlIGVmZmVj
dCwgc28gdGhlIGxvZ2ljYWwgbGV2ZWwgd2hpY2ggaXMgZ29pbmcgdG8gYmUNCj4gcmVhZCBtYXkg
YmUgaW5jb3JyZWN0Lg0KDQpObywgdGhlIHByb2JsZW0gaXMgdGhhdCB0aGUgZGF0YSBsaW5lcyBh
cmUgYmVpbmcgY2hhbmdlZCBhdCBtdWNoIHRoZSBzYW1lIHRpbWUNCmFzIHRoZSBjbG9jay4NClF1
aXRlIHBvc3NpYmx5IG9uIGJvdGggdGhlIHJpc2luZyBhbmQgZmFsbGluZyBlZGdlcyBvZiB0aGUg
Y2xvY2suDQoNClRoZSBhY3R1YWwgbGF0Y2hpbmcgb2YgdGhlIGRhdGEgcmVxdWlyZXMgdGhlIGRh
dGEgdG8gYmUgc3RhYmxlIGZvciB0aGUgJ3NldHVwJw0KYW5kICdob2xkJyB0aW1lcyBvZiB0aGUg
bGF0Y2ggKGllIGJlZm9yZSBhbmQgYWZ0ZXIgdGhlIGNsb2NrIGVkZ2UpLg0KSWYgdGhlIGRhdGEg
YW5kIGNsb2NrIGNoYW5nZSBhdCB0aGUgc2FtZSB0aW1lIGl0IHdpbGwgYmUgaW5kZXRlcm1pbmF0
ZSB3aGV0aGVyDQp0aGUgb2xkIG9yIG5ldyBkYXRhIGlzIGxhdGNoZWQgKHRoZSBsYXRjaCBvdXRw
dXQgbWlnaHQgZXZlbiBvc2NpbGxhdGUpLg0KVGhlIGRlbGF5IGlzIHRoZXJlIHRvIGVuc3VyZSB0
aGF0IHRoZSBkYXRhIGlzbid0IGNoYW5naW5nIGF0IHRoZSBzYW1lIHRpbWUgYXMNCml0IGlzIHNh
bXBsZWQuDQoNCkF0IGxvd2VyIHNwZWVkIEkgc3VzcGVjdCB0aGF0IHRoZSBkYXRhIG9ubHkgY2hh
bmdlcyBvbiBvbmUgY2xvY2sgZWRnZSBhbmQgaXMNCnNhbXBsZWQgb24gdGhlIG90aGVyLg0KKEZX
SVcgdGhlIGxhdGVzdCBERFIgaGFzIGFuIGFkZGl0aW9uYWwgY2hhbmdlIGluIHRoZSBkYXRhIGhh
bGYgd2F5IGJldHdlZW4NCnRoZSBjbG9jayBlZGdlcyEpDQoNCglEYXZpZA0KDQoNCg==
