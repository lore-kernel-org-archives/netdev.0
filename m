From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 1/8] cxgb4: Add support to recognize 40G links
Date: Sat, 22 Feb 2014 23:59:34 +0000
Message-ID: <1393113574.6823.19.camel@deadeye.wl.decadent.org.uk>
References: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com>
	 <1392726375-32001-2-git-send-email-hariprasad@chelsio.com>
	 <53051E48.9050901@opengridcomputing.com> <53064459.3030106@chelsio.com>
	 <CAGVrzcbb-7sQqHyf8SS8-mUyD+LM==Z6r3Zy1rFQ72WHFveMcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-suu2ib04UBTGPSUa08kx"
Cc: Casey Leedom <leedom@chelsio.com>,
	Steve Wise <swise@opengridcomputing.com>,
	Hariprasad Shenai <hariprasad@chelsio.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, dm@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58371 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752039AbaBVX7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 18:59:46 -0500
In-Reply-To: <CAGVrzcbb-7sQqHyf8SS8-mUyD+LM==Z6r3Zy1rFQ72WHFveMcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-suu2ib04UBTGPSUa08kx
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-02-20 at 11:00 -0800, Florian Fainelli wrote:
> 2014-02-20 10:07 GMT-08:00 Casey Leedom <leedom@chelsio.com>:
> >
> > On 02/19/14 13:12, Steve Wise wrote:
> >>
> >>
> >> You probably should add SPEED_40000 to include/uapi/linux/ethtool.h as
> >> part of this series.
> >
> >
> >   I'm ~pretty sure~ that the "word on the street" was that the communit=
y
> > wanted to get away from the SPEED_XXX symbols since they simply represe=
nted
> > the values XXX.  Thus they didn't offer any real symbolic isolation fro=
m
> > weird constants, etc.  I believe that the old SPEED_XXX values were lef=
t in
> > place in order to avoid making tons of changes everywhere ...
>=20
> Not quite sure where and when you heard that, it seems a little
> disturbing to add a comment in this patch saying "this I how I should
> fix things" and not do them, especially when this is a one-liner.
[...]

Yeah, the way to fix that is to remove the comments...

Ben.

--=20
Ben Hutchings
I haven't lost my mind; it's backed up on tape somewhere.

--=-suu2ib04UBTGPSUa08kx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwk55ue/yOyVhhEJAQq+hg/9GIDKmPttO+hqtE0GLOW/mU0zhIiqOsgo
1mihaFWrHrSi8kxi2mTGbDV6GJ/guY1Z3nOQDWLVLINRQb64p7hBWZIi4H0Cd9b7
1ItdTvU63I3mrb483wEB/7CZ0uPd8J0IDJdrV25JDTiNUiko7ToNtJQFfJyJKesP
keqVTg5pyxaQYCP2y15nax9riRvemmkJe9+Suw6yp5WfruZaHfjoj+y2Hw3boKSB
4saZl52ShYhqaJq/EYi7vbgfYVlVneGzOJv1tv7ITThMahUISW2GRLKehc3VzhM/
LUbk47uR/CPMFTRCk9fRZKkSBVRbaGOvGMAng13nB7RlavecrFO1wRs+wCLoCafJ
r2L4YzvtRae2yj5JUIVOgLlFRs7cHbVdCXDKe5Q9WklBnz5Aa7wz2ZHMpxTlFbDB
Bxae0t334ZZ1N7V9rPHpp2twg3NHolC/3XX/sVrAhQ1oqz3W7imVMC9WCAe6t95s
JQfPXJhtBH9fH8NHZVcLG9m0hOolnpymMD6NHg4a7MiEBwBGn9DAICgBNkgGvHNa
2Cma39NrxwoFcvuKtsv8VvVMN3GGpDitOeM1KYymYgbasdDay2cNmaM2PctX0DWm
zlrImTpnGOYGClzCDnC8kIajELS49M3KJgGc0LxILEBuvPPvl9/WvAj8SlQH/uIe
+qouFVbGsb8=
=xjUU
-----END PGP SIGNATURE-----

--=-suu2ib04UBTGPSUa08kx--
