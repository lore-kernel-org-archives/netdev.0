From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 1/3] net/mlx5e: use %pad format string for
 dma_addr_t
Date: Thu, 08 Dec 2016 21:31:04 -0500 (EST)
Message-ID: <20161208.213104.76575961025040529.davem@davemloft.net>
References: <20161208215727.44841-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        danielj-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: arnd-r2nGTMty4D4@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161208215727.44841-1-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

RnJvbTogQXJuZCBCZXJnbWFubiA8YXJuZEBhcm5kYi5kZT4NCkRhdGU6IFRodSwgIDggRGVjIDIw
MTYgMjI6NTc6MDMgKzAxMDANCg0KPiBPbiAzMi1iaXQgQVJNIHdpdGggNjQtYml0IGRtYV9hZGRy
X3QgSSBnZXQgdGhpcyB3YXJuaW5nIGFib3V0IGFuDQo+IGluY29ycmVjdCBmb3JtYXQgc3RyaW5n
Og0KPiANCj4gSW4gZmlsZSBpbmNsdWRlZCBmcm9tIC9naXQvYXJtLXNvYy9kcml2ZXJzL25ldC9l
dGhlcm5ldC9tZWxsYW5veC9tbHg1L2NvcmUvYWxsb2MuYzo0MjowOg0KPiBkcml2ZXJzL25ldC9l
dGhlcm5ldC9tZWxsYW5veC9tbHg1L2NvcmUvYWxsb2MuYzogSW4gZnVuY3Rpb24goW1seDVfZnJh
Z19idWZfYWxsb2Nfbm9kZaI6DQo+IGRyaXZlcnMvbmV0L2V0aGVybmV0L21lbGxhbm94L21seDUv
Y29yZS9hbGxvYy5jOjEzNDoxMjogZXJyb3I6IGNhc3QgdG8gcG9pbnRlciBmcm9tIGludGVnZXIg
b2YgZGlmZmVyZW50IHNpemUgWy1XZXJyb3I9aW50LXRvLXBvaW50ZXItY2FzdF0NCj4gDQo+IFdl
IGhhdmUgdGhlIHNwZWNpYWwgJXBhZCBmb3JtYXQgZm9yIHByaW50aW5nIGRtYV9hZGRyX3QsIHNv
IHVzZSB0aGF0DQo+IHRvIHByaW50IHRoZSBjb3JyZWN0IGFkZHJlc3MgYW5kIGF2b2lkIHRoZSB3
YXJuaW5nLg0KPiANCj4gRml4ZXM6IDFjMWI1MjI4MDhhMSAoIm5ldC9tbHg1ZTogSW1wbGVtZW50
IEZyYWdtZW50ZWQgV29yayBRdWV1ZSAoV1EpIikNCj4gU2lnbmVkLW9mZi1ieTogQXJuZCBCZXJn
bWFubiA8YXJuZEBhcm5kYi5kZT4NCg0KQXBwbGllZC4NCg==
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
