From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Fw: [Bug 65261] New: Packet loss or excessive packet delay
 repeatedly for some seconds
Date: Sat, 23 Nov 2013 16:45:58 +0000
Message-ID: <1385225158.20467.70.camel@deadeye.wl.decadent.org.uk>
References: <20131120122316.77ce76c5@nehalam.linuxnetplumber.net>
	 <20131123043359.GC15822@order.stressinduktion.org>
	 <20131123121140.GB28775@tansi.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Du/U9XhXsqmklmblGn/W"
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: Arno Wagner <arno@wagner.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53582 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753922Ab3KWQqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 11:46:10 -0500
In-Reply-To: <20131123121140.GB28775@tansi.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Du/U9XhXsqmklmblGn/W
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-11-23 at 13:11 +0100, Arno Wagner wrote:
> On Sat, Nov 23, 2013 at 05:33:59 CET, Hannes Frederic Sowa wrote:
[...]
> > Could you try dropwatch while the packet drops are happening?
> > Often it is helpful to check ip monitor all if events happen during bur=
sty
> > losses.
>=20
> Sorry, but dropwatch is not in Debian and compiling it from sources
> seem to require something called "rpmbuild". Hence I cannot use
> it or at least would have to write my own Makefile for it.=20

You could use 'perf script net_dropmonitor' instead.

Ben.

--=20
Ben Hutchings
The generation of random numbers is too important to be left to chance.
                                                            - Robert Coveyo=
u

--=-Du/U9XhXsqmklmblGn/W
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUpDbxue/yOyVhhEJAQovuQ/+L0TA2n6T6qLb4Z2/x5kf2hJYqRt76UOL
9b4j8TF2d/VhNC7hEadqbqFLwXKwPJebo9SWwCSGrQ9hnqhqouZFlxFgsL1S8mnu
175zcJ68kBSj+64C5oaMc3EKpeaeg5/P3TUrZuFaOhYLKiXon2V41/dZWZ+1sMew
9U1OAbiN/cABbWbMdJnBW91Umrh3KByMpeXmuUn6Ywb2g35HGVcxpcVCtPr1FYsV
6ZP5IRdtSQJggJk01BruE9I3aoX5ANib2oLYUDxYPVU6ap0ym5yaGxmIH9MdMP1L
e6cUnl4Ku0ZqXj1HVd/PqMI50iLs6yhLrL8Hf0o1bgmXVfoozM15TbkUtVSU56bP
9NyoGTVFstrrHD/GzF95xhjMQy7l2YrA3XzzGUbQnfCSypCsQmfh4Di21vYPYZvF
A/emhRIblj2iEPJRZdQ7D3JoDYROR2Bc3amxCWO8eyXD2SS31aPId4+OL5xk03NR
5nzlOXG4CWlZueHO0oRM4k4leMZDDGt2Xxtkof8DvZGRxl9KhUuh8wrbwrrbWsV4
PaVbFfW8SQk8fIFxZJ8Akppma1O/n1Nco3WJ3AwDM4y2LMkeVKqw13TdQ+mQsRjS
94+PPReCbVWTjJc54qLoiNfFfrV82TFzBr1fBs1qQEITXDog1eWJBykj2Vx9QB0b
1WVkvTMnGdE=
=YqsQ
-----END PGP SIGNATURE-----

--=-Du/U9XhXsqmklmblGn/W--
