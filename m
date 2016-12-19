From: Jerome Brunet <jbrunet@baylibre.com>
Subject: Re: [PATCH net-next v4 2/4] dt-bindings: net: add EEE capability
 constants
Date: Mon, 19 Dec 2016 16:16:47 +0100
Message-ID: <1482160607.5163.16.camel@baylibre.com>
References: <1480348229-25672-1-git-send-email-jbrunet@baylibre.com>
 <1480348229-25672-3-git-send-email-jbrunet@baylibre.com>
 <20161205143942.f3w6nmp3jvmrk5es@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: devicetree@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
 Alexandre TORGUE <alexandre.torgue@st.com>, Andrew Lunn <andrew@lunn.ch>,
 Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
 netdev@vger.kernel.org, Neil Armstrong <narmstrong@baylibre.com>,
 linux-kernel@vger.kernel.org, Yegor Yefremov <yegorslists@googlemail.com>,
 Julia Lawall <julia.lawall@lip6.fr>, Andre Roth <neolynx@gmail.com>,
 Kevin Hilman <khilman@baylibre.com>, Carlo Caione <carlo@caione.org>,
 Giuseppe Cavallaro <peppe.cavallaro@st.com>, linux-amlogic@lists.infradead.org,
 Andreas =?ISO-8859-1?Q?F=E4rber?= <afaerber@suse.de>,
 linux-arm-kernel@lists.infradead.org
To: Rob Herring <robh@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20161205143942.f3w6nmp3jvmrk5es@rob-hp-laptop>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

SGkgUm9iLAoKRmlyc3QsIFRoeCBmb3IgdGhpcyBpbmZvcm1hdGlvbiBhbmQgc29ycnkgZm9yIHRo
aXMgbGF0ZSByZXBseQpBcyB5b3UgbWF5IGhhdmUgc2VlbiB5b3Vyc2VsZiwgdGhlcmUgd2FzIGxp
dHRsZSBiaXQgb2YgY29uZnVzaW9uIHdoaWxlCmRpc2N1c3NpbmcgdGhpcyBwYXRjaCBzZXJpZXMu
CgpUaGUgcG9pbnQgaXMgdGhlIHYzIHdhcyBhcHBsaWVkIGJlZm9yZSB5b3VyIHJlcGx5IChwYXRj
aGVzIDIgYW5kIDMgbm90CmNvbWJpbmVkIHVuZm9ydHVuYXRlbHkpLgpCZWNhdXNlIG9mIHRoaXMg
Y29uZnVzaW9uLCB0aGUgc2VyaWVzIG5lZWRlZCBhIGZldyBmaXhlcyB3aXRjaCByZW1vdmVzCnRo
ZSBwcmV2aW91c2x5IGFkZGVkIGJpbmRpbmdzIFswXS4KVGhpcyB0aW1lLCBJIG1hZGUgc3VyZSB0
byBtb2RpZnkgKHJlbW92ZSkgdGhlIGJpbmRpbmdzIGFsb25nIHdpdGggdGhlCmRvY3VtZW50YXRp
b24uCgpbMF06wqBodHRwOi8vbGttbC5rZXJuZWwub3JnL3IvMTQ4MjE1OTkzOC0xMzIzOS0xLWdp
dC1zZW5kLWVtYWlsLWpicnVuZXQKQGJheWxpYnJlLmNvbQoKQ2hlZXJzCkplcm9tZQoKT24gTW9u
LCAyMDE2LTEyLTA1IGF0IDA4OjM5IC0wNjAwLCBSb2IgSGVycmluZyB3cm90ZToKPiBPbiBNb24s
IE5vdiAyOCwgMjAxNiBhdCAwNDo1MDoyNlBNICswMTAwLCBKZXJvbWUgQnJ1bmV0IHdyb3RlOgo+
ID4gCj4gPiBTaWduZWQtb2ZmLWJ5OiBKZXJvbWUgQnJ1bmV0IDxqYnJ1bmV0QGJheWxpYnJlLmNv
bT4KPiA+IFRlc3RlZC1ieTogWWVnb3IgWWVmcmVtb3YgPHllZ29yc2xpc3RzQGdvb2dsZW1haWwu
Y29tPgo+ID4gVGVzdGVkLWJ5OiBBbmRyZWFzIEbDpHJiZXIgPGFmYWVyYmVyQHN1c2UuZGU+Cj4g
PiBUZXN0ZWQtYnk6IE5laWwgQXJtc3Ryb25nIDxuYXJtc3Ryb25nQGJheWxpYnJlLmNvbT4KPiA+
IC0tLQo+ID4gwqBpbmNsdWRlL2R0LWJpbmRpbmdzL25ldC9tZGlvLmggfCAxOSArKysrKysrKysr
KysrKysrKysrCj4gPiDCoDEgZmlsZSBjaGFuZ2VkLCAxOSBpbnNlcnRpb25zKCspCj4gPiDCoGNy
ZWF0ZSBtb2RlIDEwMDY0NCBpbmNsdWRlL2R0LWJpbmRpbmdzL25ldC9tZGlvLmgKPiAKPiBTZWVt
cyBjaGFuZ2VzIGFyZSB3YW50ZWQgb24gdGhpcywgYnV0IHBhdGNoZXMgMiBhbmQgMyBzaG91bGQg
YmXCoAo+IGNvbWJpbmVkLiBUaGUgaGVhZGVyIGlzIHBhcnQgb2YgdGhlIGJpbmRpbmcgZG9jLgo+
IAo+IFJvYgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18K
bGludXgtYXJtLWtlcm5lbCBtYWlsaW5nIGxpc3QKbGludXgtYXJtLWtlcm5lbEBsaXN0cy5pbmZy
YWRlYWQub3JnCmh0dHA6Ly9saXN0cy5pbmZyYWRlYWQub3JnL21haWxtYW4vbGlzdGluZm8vbGlu
dXgtYXJtLWtlcm5lbAo=
