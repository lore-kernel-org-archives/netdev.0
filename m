From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] net/stmmac: Move "#include
 <linux/platform_device.h>" to linux/stmmac.h
Date: Tue, 03 May 2011 16:09:57 -0700 (PDT)
Message-ID: <20110503.160957.104053064.davem@davemloft.net>
References: <51e0617ee964ae60313a99804f4842ac6e96c129.1304397312.git.viresh.kumar@st.com>
	<4DBF9477.5070302@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: viresh.kumar@st.com, netdev@vger.kernel.org, shiraz.hashim@st.com,
	armando.visconti@st.com, deepak.sikri@st.com,
	viresh.linux@gmail.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51781
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752299Ab1ECXKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2011 19:10:30 -0400
In-Reply-To: <4DBF9477.5070302@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogR2l1c2VwcGUgQ0FWQUxMQVJPIDxwZXBwZS5jYXZhbGxhcm9Ac3QuY29tPg0KRGF0ZTog
VHVlLCAwMyBNYXkgMjAxMSAwNzozNjo1NSArMDIwMA0KDQo+IE9uIDUvMy8yMDExIDY6MzYgQU0s
IFZpcmVzaCBLdW1hciB3cm90ZToNCj4+IHN0bW1hYy5oIHVzZXMgc3RydWN0IHBsYXRmb3JtX2Rl
dmljZSBhbmQgZG9lc24ndCBpbmNsdWRlDQo+PiA8bGludXgvcGxhdGZvcm1fZGV2aWNlLmg+LiBX
aGVyZWFzIGRyaXZlcnMvbmV0L3N0bW1hYy9zdG1tYWMuaCBpbmNsdWRlcyBpdCwgYnV0DQo+PiBk
b2Vzbid0IGRpcmVjdGx5IHVzZSBpdC4gQW5kIHNvIHdlIGdldCBmb2xsb3dpbmcgY29tcGlsYXRp
b24gd2FybmluZyB3aGlsZSB1c2luZw0KPj4gdGhpcyBmaWxlOg0KPj4gCXdhcm5pbmc6IKFzdHJ1
Y3QgcGxhdGZvcm1fZGV2aWNloiBkZWNsYXJlZCBpbnNpZGUgcGFyYW1ldGVyIGxpc3QNCj4+IA0K
Pj4gVGhpcyBwYXRjaCBpbmNsdWRlcyA8bGludXgvcGxhdGZvcm1fZGV2aWNlLmg+IGluIGxpbnV4
L3N0bW1hYy5oIGFuZCByZW1vdmVzIGl0DQo+PiBmcm9tIGRyaXZlcnMvbmV0L3N0bW1hYy9zdG1t
YWMuaA0KPj4gDQo+PiBTaWduZWQtb2ZmLWJ5OiBWaXJlc2ggS3VtYXIgPHZpcmVzaC5rdW1hckBz
dC5jb20+DQo+IA0KPiBBY2tlZC1ieTogR2l1c2VwcGUgQ2F2YWxsYXJvIDxwZXBwZS5jYXZhbGxh
cm9Ac3QuY29tPg0KDQpBcHBsaWVkIHRvIG5ldC1uZXh0LTIuNiwgdGhhbmtzIGV2ZXJ5b25lLg0K
