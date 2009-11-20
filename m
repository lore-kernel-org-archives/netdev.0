From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ixgbe: move tc variable to CONFIG_IXGBE_DCB
Date: Fri, 20 Nov 2009 11:13:55 -0800 (PST)
Message-ID: <20091120.111355.141716974.davem@davemloft.net>
References: <1258725747.3562.5.camel@ht.satnam>
	<9929d2390911200624mf352c28u55a8b2aee8b52fa3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: jaswinder@kernel.org, yi.zou@intel.com,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47663
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752390AbZKTTNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 14:13:38 -0500
In-Reply-To: <9929d2390911200624mf352c28u55a8b2aee8b52fa3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSmVmZiBLaXJzaGVyIDxqZWZmcmV5LnQua2lyc2hlckBpbnRlbC5jb20+DQpEYXRlOiBG
cmksIDIwIE5vdiAyMDA5IDA2OjI0OjIxIC0wODAwDQoNCj4gT24gRnJpLCBOb3YgMjAsIDIwMDkg
YXQgMDY6MDIsIEphc3dpbmRlciBTaW5naCBSYWpwdXQNCj4gPGphc3dpbmRlckBrZXJuZWwub3Jn
PiB3cm90ZToNCj4+DQo+PiB0YyBpcyByZXF1aXJlZCBieSBDT05GSUdfSVhHQkVfRENCLg0KPj4g
VGhpcyBhbHNvIGZpeGVzIGNvbXBpbGF0aW9uIHdhcm5pbmc6DQo+Pg0KPj4gwqBkcml2ZXJzL25l
dC9peGdiZS9peGdiZV9tYWluLmM6IEluIGZ1bmN0aW9uIOKAmGl4Z2JlX3R4X2lzX3BhdXNlZOKA
mToNCj4+IMKgZHJpdmVycy9uZXQvaXhnYmUvaXhnYmVfbWFpbi5jOjI0NTogd2FybmluZzogdW51
c2VkIHZhcmlhYmxlIOKAmHRj4oCZDQo+Pg0KPj4gU2lnbmVkLW9mZi1ieTogSmFzd2luZGVyIFNp
bmdoIFJhanB1dCA8amFzd2luZGVycmFqcHV0QGdtYWlsLmNvbT4NCiAuLi4NCj4gSSBqdXN0IHN1
Ym1pdHRlZCBhIHBhdGNoIHRvIGZpeCB0aGlzLiAgU28gTkFLLg0KDQpCdXQgaGlzIGlzIG11Y2gg
Y2xlYW5lciB0aGF0IHlvdXIncywgbGVzcyBpZmRlZnMuICBJIHRoaW5rIHdlDQpzaG91bGQgdGhl
cmVmb3JlIHVzZSBKYXNkaW5kZXIncyB2ZXJzaW9uLg0KDQo=
