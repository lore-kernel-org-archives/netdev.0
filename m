From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 3/5 v2] ARM: kirkwood: add device node entries for the
 gigabit interfaces
Date: Fri, 05 Apr 2013 11:21:50 +0200
Message-ID: <515E97AE.4080608@openwrt.org>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
 <1365071235-11611-4-git-send-email-florian@openwrt.org>
 <20130404213517.GB25904@schnuecks.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: thomas.petazzoni@free-electrons.com, moinejf@free.fr, jason@lakedaemon.net,
 andrew@lunn.ch, netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
 rob.herring@calxeda.com, grant.likely@secretlab.ca, jogo@openwrt.org,
 linux-arm-kernel@lists.infradead.org, jm@lentin.co.uk, davem@davemloft.net,
 buytenh@wantstofly.org, sebastian.hesselbarth@gmail.com
To: Simon Baatz <gmbnomis@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20130404213517.GB25904@schnuecks.de>
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

TGUgMDQvMDQvMTMgMjM6MzUsIFNpbW9uIEJhYXR6IGEgw6ljcml0IDoKPiBIaSBGbG9yaWFuLAo+
Cj4gT24gVGh1LCBBcHIgMDQsIDIwMTMgYXQgMTI6Mjc6MTNQTSArMDIwMCwgRmxvcmlhbiBGYWlu
ZWxsaSB3cm90ZToKPj4gVGhpcyBwYXRjaCBtb2RpZmllcyBraXJrd29vZC5kdHNpIHRvIHNwZWNp
ZnkgdGhlIHZhcmlvdXMgZ2lnYWJpdAo+PiBpbnRlcmZhY2VzIG5vZGVzIGF2YWlsYWJsZSBvbiBr
aXJrd29vZCBkZXZpY2VzLiBUaGV5IGFyZSBkaXNhYmxlZCBieQo+PiBkZWZhdWx0IGFuZCBzaG91
bGQgYmUgZW5hYmxlZCBvbiBhIHBlci1ib2FyZCBiYXNpcy4gZWdpZ2EwIGFuZCBlZ2lnYTEKPj4g
YWxpYXNlcyBhcmUgZGVmaW5lZCBmb3IgY29udmVuaWVuY2UuIFRoZSBtZGlvIG5vZGUgaXMgYWxz
byBwcmVzZW50IGFuZAo+PiBzaG91bGQgYmUgZW5hYmxlZCBvbiBhIHBlci1ib2FyZCBiYXNpcyBh
cyB3ZWxsLgo+Pgo+PiBTaWduZWQtb2ZmLWJ5OiBGbG9yaWFuIEZhaW5lbGxpIDxmbG9yaWFuQG9w
ZW53cnQub3JnPgo+PiAtLS0KPj4gQ2hhbmdlcyBzaW5jZSB2MToKPj4gLSBkcm9wcGVkIGNoYW5n
ZSB0byBhcmNoL2FybS9tYWNoLWtpcmt3b29kL2NvbW1vbi5jIHRvIGF2b2lkIG1lcmdlIGNvbmZs
aWN0cwo+Cj4gSSB0aGluayB3ZSBzaG91bGQgcmVtb3ZlIHRoZSBjbG9jayBhbGlhc2VzIGluCj4g
a2lya3dvb2RfbGVnYWN5X2Nsa19pbml0KCkgaW4gbWFjaC1raXJrd29vZC9kdC1ib2FyZC5jIChv
bmNlIHdlIGhhdmUKPiBwcm9wZXIgY2xvY2sgc3VwcG9ydCwgc2VlIG15IG90aGVyIG1haWwpLgo+
CltzbmlwXQo+Cj4gRG9uJ3Qgd2UgbmVlZCB0byBhZGQ6Cj4KPiAJCQlpbnRlcnJ1cHRzID0gPDQ2
PjsKPgo+IGhlcmU/CgpSaWdodCB0aGlzIGlzIG1pc3NpbmcsIGluIGZhY3QgaXQgc3RpbGwgd29y
a3Mgb2sgYmVjYXVzZSB0aGUgb3Jpb24tbWRpbyAKZHJpdmVyIGNhbiBkbyBidXN5IHdhaXRpbmcg
aW5zdGVhZCBvZiBpbnRlcnJ1cHQgc2lnbmFsaW5nLiBXaWxsIGZpeCB0aGF0IAppbiB0aGUgbmV4
dCByb3VuZCwgdGhhbmtzIQotLQpGbG9yaWFuCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fXwpsaW51eC1hcm0ta2VybmVsIG1haWxpbmcgbGlzdApsaW51eC1h
cm0ta2VybmVsQGxpc3RzLmluZnJhZGVhZC5vcmcKaHR0cDovL2xpc3RzLmluZnJhZGVhZC5vcmcv
bWFpbG1hbi9saXN0aW5mby9saW51eC1hcm0ta2VybmVsCg==
