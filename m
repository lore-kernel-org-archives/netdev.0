From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 19/39] i2400m: sysfs controls
Date: Thu, 27 Nov 2008 10:23:04 +0100
Message-ID: <1227777785.3809.8.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <8393b57d107460e5b17e0329751fde2b46ccfb62.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-wZitxjf2dCyKnzyWLCIl"
Cc: netdev <netdev@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:43393 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045AbYK0JXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 04:23:47 -0500
In-Reply-To: <8393b57d107460e5b17e0329751fde2b46ccfb62.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wZitxjf2dCyKnzyWLCIl
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:
> Expose knobs to control the device (induce reset, power saving,
> querying tx or rx stats, internal debug information and debug level
> manipulation).

Seems all of that would be better in debugfs rather than making it part
of some userspace ABI? Do you actually use this in programs (rather than
manually, test tools don't count) in userspace?

johannes

--=-wZitxjf2dCyKnzyWLCIl
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJLmb1AAoJEKVg1VMiehFYjcwQAKDv92Kc0NuC4+c2i6PHrTV4
+m+2Q2mz6EK2uAdrgUJJxia7s6q6nTZmAffCVub6C1IG3D3wEQt/LZo2UbrncjBQ
dUoz+FNCaXtuwUutUv0he43CcHhbSTU+uM20+Q1Wt08bp2MuuoDiIcS3noPiZF1J
GlLwR/DBlTHdm1lhAkH8sEtG7zWrqaPDo51ScVg88izyRPqa8HLukm0SHhgYcmIs
KlkJrqRqbisszHuWnLHklDIRxlxDw5NlbdDx79i79BYJSFq0r1UWWJ1XJdVEDqlJ
rDcuZ1o9lxjmM+Hcu5ME5Dp9LVtuIwGNfvqDwhRVlyMUIy/gJ+tABOUBqizjQFp2
Z6cjadAMlbxnyqyvF53p9RmP4J/vMRx/rBV2wVdWF+vZP4HhsR2RhjopzUun6PjV
N2h1ol+pkOjvR+9yjM3vp4BLr7Q/WkHI1t+mdZJYSrZpr+AL+m8qGu1rUKuIowmC
uVo9w1F77WXXHupEiTCHOFCPWU9GKr6toHHP+YuHwmlRVDa6u2nz9FDGmh1QUTBl
fijwiGwcTMB3im4+C0t9Al6l3u7rcGxRkxGpcd9aysRLYOyuW2gM64aqQutwiszJ
aq+Hg2ZRNDhhPmNJJG1LEYEAx/AvwZm64xE49Wwjtq8RexHpTrZ2ZRzVr/cYJHKB
NCCRLrxwo6ZvH8fXOdDX
=dMER
-----END PGP SIGNATURE-----

--=-wZitxjf2dCyKnzyWLCIl--

