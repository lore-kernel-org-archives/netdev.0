From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: vrf: avoid gcc-4.6 warning
Date: Fri, 15 Sep 2017 14:22:44 -0700 (PDT)
Message-ID: <20170915.142244.2005612745314498019.davem@davemloft.net>
References: <20170912201100.3680915-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: dsa@cumulusnetworks.com, shm@cumulusnetworks.com, ja@ssi.bg,
        mschiffer@universe-factory.net, weiwan@google.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170912201100.3680915-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogQXJuZCBCZXJnbWFubiA8YXJuZEBhcm5kYi5kZT4NCkRhdGU6IFR1ZSwgMTIgU2VwIDIw
MTcgMjI6MTA6NTMgKzAyMDANCg0KPiBXaGVuIGJ1aWxkaW5nIGFuIGFsbG1vZGNvbmZpZyBrZXJu
ZWwgd2l0aCBnY2MtNC42LCB3ZSBnZXQgYSByYXRoZXINCj4gb2RkIHdhcm5pbmc6DQo+IA0KPiBk
cml2ZXJzL25ldC92cmYuYzogSW4gZnVuY3Rpb24goXZyZl9pcDZfaW5wdXRfZHN0ojoNCj4gZHJp
dmVycy9uZXQvdnJmLmM6OTY0OjM6IGVycm9yOiBpbml0aWFsaXplZCBmaWVsZCB3aXRoIHNpZGUt
ZWZmZWN0cyBvdmVyd3JpdHRlbiBbLVdlcnJvcl0NCj4gZHJpdmVycy9uZXQvdnJmLmM6OTY0OjM6
IGVycm9yOiAobmVhciBpbml0aWFsaXphdGlvbiBmb3IgoWZsNqIpIFstV2Vycm9yXQ0KPiANCj4g
SSBoYXZlIG5vIGlkZWEgd2hhdCB0aGlzIHdhcm5pbmcgaXMgZXZlbiB0cnlpbmcgdG8gc2F5LCBi
dXQgaXQgZG9lcw0KPiBzZWVtIGxpa2UgYSBmYWxzZSBwb3NpdGl2ZS4gUmVvcmRlcmluZyB0aGUg
aW5pdGlhbGl6YXRpb24gaW4gdG8gbWF0Y2gNCj4gdGhlIHN0cnVjdHVyZSBkZWZpbml0aW9uIGdl
dHMgcmlkIG9mIHRoZSB3YXJuaW5nLCBhbmQgbWlnaHQgYWxzbyBhdm9pZA0KPiB3aGF0ZXZlciBn
Y2MgdGhpbmtzIGlzIHdyb25nIGhlcmUuDQo+IA0KPiBGaXhlczogOWZmNzQzODQ2MDBhICgibmV0
OiB2cmY6IEhhbmRsZSBpcHY2IG11bHRpY2FzdCBhbmQgbGluay1sb2NhbCBhZGRyZXNzZXMiKQ0K
PiBTaWduZWQtb2ZmLWJ5OiBBcm5kIEJlcmdtYW5uIDxhcm5kQGFybmRiLmRlPg0KDQpUaGF0J3Mg
ZXh0cmVtZWx5IHdlaXJkLCBJIGNhbid0IGV4cGxhaW4gaXQgZWl0aGVyLg0KDQpPaCB3ZWxsLCBh
cHBsaWVkLCB0aGFua3MuDQo=
