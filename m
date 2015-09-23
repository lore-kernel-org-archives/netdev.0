From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 0/9] Phy, mdiobus, and netdev struct device fixes
Date: Wed, 23 Sep 2015 16:24:17 -0700 (PDT)
Message-ID: <20150923.162417.814596822188458346.davem@davemloft.net>
References: <20150922161710.GA21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	isubramanian-qTEPVZfXA3Y@public.gmane.org, kchudgar-qTEPVZfXA3Y@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org,
	michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rric-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	sgoutham-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
To: linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150922161710.GA21084-l+eeeJia6m9vn6HldHNs0ANdhmdF6hFW@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

RnJvbTogUnVzc2VsbCBLaW5nIC0gQVJNIExpbnV4IDxsaW51eEBhcm0ubGludXgub3JnLnVrPg0K
RGF0ZTogVHVlLCAyMiBTZXAgMjAxNSAxNzoxNzoxMCArMDEwMA0KDQo+IFRoaXMgaXMgdGhlIHNl
Y29uZCB2ZXJzaW9uIG9mIHRoZSBzZXJpZXMsIHdpdGggdGhlIGNvbW1lbnRzIERhdmlkIGhhZA0K
PiBvbiB0aGUgZmlyc3QgcGF0Y2ggZml4ZWQgdXAuICBPcmlnaW5hbCBzZXJpZXMgZGVzY3JpcHRp
b24gd2l0aCB1cGRhdGVkDQo+IGRpZmZzdGF0IGJlbG93Lg0KDQpUaGlzIG5lZWRzIHNvbWUgYnVp
bGQgZml4ZXM6DQoNCmRyaXZlcnMvbmV0L2V0aGVybmV0L2FwbS94Z2VuZS94Z2VuZV9lbmV0X2h3
LmM6IEluIGZ1bmN0aW9uIKF4Z2VuZV9lbmV0X3BoeV9jb25uZWN0ojoNCmRyaXZlcnMvbmV0L2V0
aGVybmV0L2FwbS94Z2VuZS94Z2VuZV9lbmV0X2h3LmM6Njk0OjIwOiBlcnJvcjogdG9vIGZldyBh
cmd1bWVudHMgdG8gZnVuY3Rpb24goW9mX3BoeV9jb25uZWN0og0KICAgcGRhdGEtPnBoeV9kZXYg
PSBvZl9waHlfY29ubmVjdChuZGV2LCBwaHlfbnAsDQogICAgICAgICAgICAgICAgICAgIF4NCklu
IGZpbGUgaW5jbHVkZWQgZnJvbSBkcml2ZXJzL25ldC9ldGhlcm5ldC9hcG0veGdlbmUveGdlbmVf
ZW5ldF9tYWluLmg6MzE6MCwNCiAgICAgICAgICAgICAgICAgZnJvbSBkcml2ZXJzL25ldC9ldGhl
cm5ldC9hcG0veGdlbmUveGdlbmVfZW5ldF9ody5jOjIyOg0KaW5jbHVkZS9saW51eC9vZl9tZGlv
Lmg6MTg6Mjc6IG5vdGU6IGRlY2xhcmVkIGhlcmUNCiBleHRlcm4gc3RydWN0IHBoeV9kZXZpY2Ug
Km9mX3BoeV9jb25uZWN0KHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsDQogICAgICAgICAgICAgICAg
ICAgICAgICAgICBeDQo=
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
