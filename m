From: Didier LINK <didier.link@wanadoo.fr>
Subject: Re: Latest fixes to bcm43xx-d80211 now available as patch to 2.6.18
Date: Fri, 06 Oct 2006 18:47:28 +0200
Message-ID: <1160153248.16584.1.camel@neutrino.cosmos.net>
References: <45259659.9040804@lwfinger.net>
	 <51ad2e0d0610060137n5cc2bf4cna4a4a68ccedd94e@mail.gmail.com>
	 <45268352.7010504@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Ob5fbV4tumyeK5MKPMr/"
Cc: Bin Zhang <yangtze31@gmail.com>, netdev <netdev@vger.kernel.org>,
	Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp13.orange.fr ([193.252.22.54]:63112 "EHLO
	smtp-msa-out13.orange.fr") by vger.kernel.org with ESMTP
	id S1161060AbWJFQra (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Oct 2006 12:47:30 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <45268352.7010504@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Ob5fbV4tumyeK5MKPMr/
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Le vendredi 06 octobre 2006 =E0 11:24 -0500, Larry Finger a =E9crit :
> Bin Zhang wrote:
> >  CC [M]  drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.o
> >  LD [M]  drivers/net/wireless/d80211/bcm43xx/bcm43xx-d80211.o
> >  LD      drivers/net/wireless/built-in.o
> > ld: drivers/net/wireless/d80211/built-in.o: No such file: No such file
> > or directory
> > make[3]: *** [drivers/net/wireless/built-in.o] Error 1
> > make[2]: *** [drivers/net/wireless] Error 2
> > make[1]: *** [drivers/net] Error 2
> > make: *** [drivers] Error 2
>=20
> Initially I had seen that error, but thought it was fixed. A new version =
has been uploaded that=20
> builds correctly from a 'make clean' - please try it.

Fixed for the kernel build, thanks !

In test for the driver ;)

Regards

Didier

--=20
Didier Link <didier.link@wanadoo.fr>
Jabber : zanfib@ims.kelkoo.net
MSN : zanfib@hotmail.fr
SIP : Zanfib@ekiga.net

Cl=E9 GPG : 75BAC9EE

--=-Ob5fbV4tumyeK5MKPMr/
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Ceci est une partie de message
	=?ISO-8859-1?Q?num=E9riquement?= =?ISO-8859-1?Q?_sign=E9e?=

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBFJoigkyPwinW6ye4RAty9AJ9RterCv/0QlnnfW07kA9664RYzwQCePI1S
3xrcaiFvjXLbbvJYh/WlXJA=
=vbV9
-----END PGP SIGNATURE-----

--=-Ob5fbV4tumyeK5MKPMr/--

