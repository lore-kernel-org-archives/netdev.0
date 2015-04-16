From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: Add missing initialization in
 mv88e6xxx_set_port_state()
Date: Thu, 16 Apr 2015 15:34:23 -0400 (EDT)
Message-ID: <20150416.153423.2060745319495574933.davem@davemloft.net>
References: <1429210154-21805-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: linux@roeck-us.net, andrew@lunn.ch, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35283 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbbDPTeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 15:34:25 -0400
In-Reply-To: <1429210154-21805-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogR2VlcnQgVXl0dGVyaG9ldmVuIDxnZWVydEBsaW51eC1tNjhrLm9yZz4NCkRhdGU6IFRo
dSwgMTYgQXByIDIwMTUgMjA6NDk6MTQgKzAyMDANCg0KPiBkcml2ZXJzL25ldC9kc2EvbXY4OGU2
eHh4LmM6IEluIGZ1bmN0aW9uIKFtdjg4ZTZ4eHhfc2V0X3BvcnRfc3RhdGWiOg0KPiBkcml2ZXJz
L25ldC9kc2EvbXY4OGU2eHh4LmM6OTA1OiB3YXJuaW5nOiChcmV0oiBtYXkgYmUgdXNlZCB1bmlu
aXRpYWxpemVkIGluIHRoaXMgZnVuY3Rpb24NCj4gDQo+IElmIG9sZHN0YXRlID09IHN0YXRlLCBt
djg4ZTZ4eHhfc2V0X3BvcnRfc3RhdGUoKSB3aWxsIHJldHVybiBhbg0KPiB1bmluaXRpYWxpemVk
IHZhbHVlLiBQcmUtaW5pdGlhbGl6ZSByZXQgdG8gemVybyB0byBmaXggdGhpcy4NCj4gDQo+IFNp
Z25lZC1vZmYtYnk6IEdlZXJ0IFV5dHRlcmhvZXZlbiA8Z2VlcnRAbGludXgtbTY4ay5vcmc+DQoN
CkluZGVlZCwgYXBwbGllZCwgdGhhbmtzIEdlZXJ0Lg0K
