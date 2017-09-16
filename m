From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] Documentation: fix ascii art in networking docs
Date: Sat, 16 Sep 2017 21:25:19 +0200
Message-ID: <20170916192519.GA17916@amd>
References: <20170916162217.GA11237@amd>
 <87efr65wyg.fsf@linux-m68k.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="/9DWx/yDrRhgMJTb"
Cc: "David S. Miller" <davem@davemloft.net>,
        Netdev list <netdev@vger.kernel.org>
To: Andreas Schwab <schwab@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:40722 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751272AbdIPTZV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 16 Sep 2017 15:25:21 -0400
Content-Disposition: inline
In-Reply-To: <87efr65wyg.fsf@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--/9DWx/yDrRhgMJTb
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat 2017-09-16 20:18:15, Andreas Schwab wrote:
> On Sep 16 2017, Pavel Machek <pavel@ucw.cz> wrote:
>=20
> > diff --git a/Documentation/networking/switchdev.txt b/Documentation/net=
working/switchdev.txt
> > index 5e40e1f..6309e90 100644
> > --- a/Documentation/networking/switchdev.txt
> > +++ b/Documentation/networking/switchdev.txt
> > @@ -29,7 +29,7 @@ with SR-IOV or soft switches, such as OVS, are possib=
le.
> >  =E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89sw1p1=E2=80=89 +  sw1=
p3  + =E2=80=89sw1p5  +  =E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89eth1
> >  =E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89+=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89+=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89+=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89+
> >  =E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|
> > -=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89+--+----+----+----+-+--+----+-=
--+=E2=80=89=E2=80=89+-----+-----+
> > +=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89+--+----+----+----+----+----+-=
--+=E2=80=89=E2=80=89+-----+-----+
> >  =E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89Switch=E2=80=89driver=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89|=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89mgmt=E2=80=89=
=E2=80=89=E2=80=89|
> >  =E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89(this=E2=80=89document)=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=
=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89driver=E2=80=89=E2=80=89|
> >  =E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|
> >
>=20
> This is all mis-aligned.  How about replacing all the thin space
> characters by normal spaces?

It looked perfectly ok to me, in emacs. If you see a problem, please
submit followup patch.
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--/9DWx/yDrRhgMJTb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlm9ep8ACgkQMOfwapXb+vIOQwCfZsON34ffep4p/RjQtcrgo5+D
hwIAoKL/vFTz+ynJVArmozDZJTQYJIRY
=dRwK
-----END PGP SIGNATURE-----

--/9DWx/yDrRhgMJTb--
