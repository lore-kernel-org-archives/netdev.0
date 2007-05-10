From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: support for bridging ethernet and 802.11
Date: Thu, 10 May 2007 19:06:21 +0200
Message-ID: <1178816781.3806.31.camel@johannes.berg>
References: <CCA1D7C0-D44A-450D-A76E-DAE792E0CB37@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-/+vkCqKKoBzGwJSRtpku"
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CCA1D7C0-D44A-450D-A76E-DAE792E0CB37-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-/+vkCqKKoBzGwJSRtpku
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

[adding linux-wireless]

On Thu, 2007-05-10 at 11:18 -0500, Kumar Gala wrote:
> I'm wondering how to tell if a given driver/device in the kernel =20
> supports the ability to bridge between ethernet and 802.11.  From =20
> searching the web it looks like only the prism driver/device supports =20
> this.

Normally wireless drivers do 802.3 framing as the 802.11 standard more
or less requires, so it should "just work". Am I missing something?

johannes

--=-/+vkCqKKoBzGwJSRtpku
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGQ1EN/ETPhpq3jKURAtqGAJ9iAYgHtJeWKEiPsz/7F5gpHpqlhQCdEtLp
E6ksXe33JxxG+rne2UzRPiI=
=oCG2
-----END PGP SIGNATURE-----

--=-/+vkCqKKoBzGwJSRtpku--
