From: Ian Kumlien <pomac@vapor.com>
Subject: Re: [PATCH] Revert sky2 to 0.13a
Date: Sun, 26 Feb 2006 03:25:51 +0100
Message-ID: <1140920751.24553.2.camel@localhost>
References: <4400FC28.1060705@gmx.net>
Reply-To: pomac@vapor.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-kBTnxv2R3TdkpzmmWEAp"
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Wolfgang Hoffmann <woho@woho.de>,
	Pavel Volkovitskiy <int@mtx.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751172AbWBZCZi@vger.kernel.org>
To: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>
In-Reply-To: <4400FC28.1060705@gmx.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-kBTnxv2R3TdkpzmmWEAp
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2006-02-26 at 01:54 +0100, Carl-Daniel Hailfinger wrote:
> Hi Jeff,
>=20
> you may want to push this patch into 2.6.16. The version it reverts to
> has been running stable for over four weeks for various folks (CC'ed)
> and we have had no success communicating with the maintainer.

I don't think that this is constructive, the error must be locatable on
later versions, just reverting to a older version of the driver as a cop
out solves nothing... And it also means that we don't understand WHY it
breaks at all.

It would be much better if more ppl could hack the driver source, esp if
they themselves have a system that shows the breakage.

--=20
Ian Kumlien <pomac () vapor ! com> -- http://pomac.netswarm.net

--=-kBTnxv2R3TdkpzmmWEAp
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.1-ecc0.1.6 (GNU/Linux)

iD8DBQBEARGv7F3Euyc51N8RAvTbAJ4u5T/BEpNAHQeJ23Vf2AOEMwupUQCeKlJD
KKEimK4Dht0xyFQ2LUVIWVA=
=bmrT
-----END PGP SIGNATURE-----

--=-kBTnxv2R3TdkpzmmWEAp--
