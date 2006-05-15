From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH wireless-dev] d80211: Don't discriminate against
	802.11b drivers
Date: Mon, 15 May 2006 14:04:44 +0200
Message-ID: <1147694684.29795.30.camel@johannes.berg>
References: <200605042232.35446.flamingice@sourmilk.net>
	 <200605101331.39960.flamingice@sourmilk.net>
	 <20060512124703.563dacd6@griffin.suse.cz>
	 <200605121635.27959.flamingice@sourmilk.net>
	 <20060515133725.3df090af@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-5ciq2a8V9ai7h0pJBHS8"
Cc: Michael Wu <flamingice@sourmilk.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jouni Malinen <jkm@devicescape.com>, netdev@vger.kernel.org,
	jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:14737 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S964902AbWEOMFg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 08:05:36 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060515133725.3df090af@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-5ciq2a8V9ai7h0pJBHS8
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2006-05-15 at 13:37 +0200, Jiri Benc wrote:
>=20
> bcm43xx does that. If I understand it correctly, bcm43xx driver doesn't
> know allowed modes until it loads firmware. And the firmware is not
> loaded until the device is opened (they probably have a reason for
> this).=20

No, that's not right, the firmware has nothing to do with it. At least
not that we know of, so we treat it as all doing the same :)

johannes

--=-5ciq2a8V9ai7h0pJBHS8
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARGhuWqVg1VMiehFYAQKzug//RB9sts56f0M9a9oRL5bMYP9TZRvOpioB
p6A6YKwk41I7IVPv4Hf5gT7fqdCc00yOpLTGqjU0FdokCUgrPO0CHr/k7w7hNGTA
tunsQ19jDnpxMxlbJzgKoRf55dzBZR5M83RY/pYi72k43UdFNzAFpIXu30e/mBhc
kAGgMd98aFRNffVj9A1J8rkubbCQM1K9OEo0mMiRsYS7AyhG72HqXpqzHM08VTjZ
SxgZG4ruoiv22CaIkSS/9+fC2kUely4AD5a4JUz/Q08/6Pbude3jiZN5ojviNBrF
jiqe2w7RnVGLgwJ5AhnwfME7+eRlesISK+2vS58OL5VyovxIaLZPywon3xAGsUM0
zJZn1CMeG/w7BagdeHPVGL3YteeuoT+U7W5d2Eoxlbc7myjcfmFAQCk8//nI+LCz
H6lnfKlMpaWUgkznlCKLR3gWPMa7NnmzdO+EJViSCqa/DQi2uuYldjXUpZbvUuMb
+CR9An2PtDrDn+Km0UUPLh8G5arqVm52KV1txV5yG36HcWU28xPhcGlfqdh5xoaI
tMrR7m3DIwnJ3Vx1PL/M4bf6puevKBWSkRLILn2/pcMMXuyouNX2tqoE/UaLXj5X
SuB+9tOQxOw2bBA5KRUnbFxvFGR3f8RlIFV0sPrZ2rldqyjs203tp9CDN9g2jHSl
XHrLeK6KI8k=
=dlqh
-----END PGP SIGNATURE-----

--=-5ciq2a8V9ai7h0pJBHS8--

