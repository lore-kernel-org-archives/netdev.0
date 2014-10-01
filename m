From: Wolfram Sang <wsa@the-dreams.de>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT
 mechanism
Date: Wed, 1 Oct 2014 13:10:34 +0200
Message-ID: <20141001111034.GC1261@katana>
References: <20140930152550.GR1325@katana>
 <542AD483.2020808@pengutronix.de>
 <542BBF3F.2040803@ti.com>
 <542BBFBE.90406@pengutronix.de>
 <542BC42F.2010406@ti.com>
 <542BD116.4090809@pengutronix.de>
 <542BD3A7.5060200@ti.com>
 <542BD6F1.2020900@pengutronix.de>
 <20141001104317.GB1261@katana>
 <542BDE32.6030309@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VywGB/WGlW4DM4P8"
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, wg@grandegger.com,
	tony@atomide.com, tglx@linutronix.de, mugunthanvnm@ti.com,
	george.cherian@ti.com, balbi@ti.com, nsekhar@ti.com, nm@ti.com,
	sergei.shtylyov@cogentembedded.com, linux-omap@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <542BDE32.6030309@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--VywGB/WGlW4DM4P8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


> Is it OK to create a new platform_data structure for CAN and put the type and raminit start/stop
> bits there?

I'd say yes, don't see a reason not to.


--VywGB/WGlW4DM4P8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUK+EqAAoJEBQN5MwUoCm2eMEP/RloTiZmXdkDtm/pNE5DJcB1
zFwS/4X8ZXyyUnoKL/ktlntk+HBsyONIeflJjtsp7MXtTqv+gLr0Kp+KvlXWbtH5
1SgK0Vg2o0//J75MTt8DYjzfIM0liGJa8hXSI8fOCMv4Zp06WqiDZLz2GDItP4KJ
IKTHu6/uEBjTSqeLjRz/TYjELV8uFeIpXJRWHudXPkfg14mF1i1Mb+1G7BrEgGWF
bRLrG1vwUGIXGttdPPPS6JwczEaV1IiffwEUxONyMKZXV6vUAEP+6nCDWdd1qccw
jOmhxju9hTaBfe1ZWAUKIQKeAelsLbEwXg29nDJZmthH6OaWk3T3qwTl0SsFusMb
ZU6/PVJMTOD9alQmhq4XFVP9bUknnGoumon+PXgDos34op6lYsCgTRS39FaqH2YM
FSMo287O6DAbwsjof3xHnDbT0TjMiB7d0HWaFsB3OgCO4VUXyVRPoYvCtYGp3gJj
4Xo4Te3xtq5/TtlThpRYpz8W8Nydl072vcLC49Ur6/UO+xpt1HsB1gA2c6XO5PEW
kStxBW3pG1HVZTQkcgUP0gLYpsPT1kevS4hbgnDlyn1GLnksFabQw5cfRw8E0f6I
vNlulQ6s0wiORXZuMUxGPFFVt66UIucZAb7h881yKIJuk5eo3wiFXCbNvtVs/N7f
0TNs1XtzNsC3Xo+aJJ3G
=8SsU
-----END PGP SIGNATURE-----

--VywGB/WGlW4DM4P8--
