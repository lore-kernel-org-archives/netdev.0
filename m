From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 8/8] drivers: net: Mark function
 xenvif_count_frag_slots() as static in netback.c
Date: Thu, 19 Dec 2013 18:52:49 -0500 (EST)
Message-ID: <20131219.185249.732943424956542038.davem@davemloft.net>
References: <04fe932bc3585620c91d511bb0894e45bb762ffa.1387382457.git.rashika.kheria@gmail.com>
	<72d6fe114ba7cc2f09f51e279313860f83142d46.1387382457.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, josh@joshtriplett.org
To: rashika.kheria@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <72d6fe114ba7cc2f09f51e279313860f83142d46.1387382457.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogUmFzaGlrYSBLaGVyaWEgPHJhc2hpa2Eua2hlcmlhQGdtYWlsLmNvbT4NCkRhdGU6IFRo
dSwgMTkgRGVjIDIwMTMgMTQ6MjY6NDcgKzA1MzANCg0KPiBUaGlzIHBhdGNoIG1hcmtzIHRoZSBm
dW5jdGlvbiB4ZW52aWZfY291bnRfZnJhZ19zbG90cygpIGluIG5ldGJhY2suYyBhcw0KPiBzdGF0
aWMgYmVjYXVzZSB0aGV5IGFyZSBub3QgdXNlZCBvdXRzaWRlIHRoaXMgZmlsZS4NCj4gDQo+IFRo
dXMsIGl0IGFsc28gcmVtb3ZlcyB0aGUgZm9sbG93aW5nIHdhcm5pbmcgaW4geGVuLW5ldGJhY2sv
bmV0YmFjay5jOg0KPiBkcml2ZXJzL25ldC94ZW4tbmV0YmFjay9uZXRiYWNrLmM6MjE4OjE0OiB3
YXJuaW5nOiBubyBwcmV2aW91cyBwcm90b3R5cGUgZm9yIKF4ZW52aWZfY291bnRfZnJhZ19zbG90
c6IgWy1XbWlzc2luZy1wcm90b3R5cGVzXQ0KPiANCj4gU2lnbmVkLW9mZi1ieTogUmFzaGlrYSBL
aGVyaWEgPHJhc2hpa2Eua2hlcmlhQGdtYWlsLmNvbT4NCj4gUmV2aWV3ZWQtYnk6IEpvc2ggVHJp
cGxldHQgPGpvc2hAam9zaHRyaXBsZXR0Lm9yZz4NCj4gQWNrZWQtYnk6IElhbiBDYW1wYmVsbCA8
aWFuLmNhbXBiZWxsQGNpdHJpeC5jb20+DQoNClRoaXMgcGF0Y2ggZG9lc24ndCBhcHBseSBjbGVh
bmx5IHRvIG5ldC1uZXh0LCBwbGVhc2UgcmVzcGluLg0KDQpUaGFua3MuDQo=
