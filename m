From: Jan-Benedict Glaw <jbglaw@lug-owl.de>
Subject: Re: [2.6 patch] make UNIX a bool
Date: Sun, 26 Mar 2006 17:20:44 +0200
Message-ID: <20060326152044.GV31387@lug-owl.de>
References: <20060225160150.GX3674@stusta.de> <20060225224631.GA4085@suse.de> <20060325194739.GS4053@stusta.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qa1NXTiqN6KSzHv0"
Cc: Olaf Hering <olh@suse.de>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751313AbWCZPUt@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20060325194739.GS4053@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--qa1NXTiqN6KSzHv0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, 2006-03-25 20:47:39 +0100, Adrian Bunk <bunk@stusta.de> wrote:
> On Sat, Feb 25, 2006 at 11:46:31PM +0100, Olaf Hering wrote:
> >  On Sat, Feb 25, Adrian Bunk wrote:
> > > CONFIG_UNIX=3Dm doesn't make much sense.
> >=20
> > There is likely more code to support a modular unix.ko, this has to go
> > as well.
>=20
> Sounds resonable, updated patch below.

Thanks for the patch. I'll save it somewhere to have it handy for
"patch -R" use IFF it makes its ways into Linus's repo.

MfG, JBG

--=20
Jan-Benedict Glaw       jbglaw@lug-owl.de    . +49-172-7608481             =
_ O _
"Eine Freie Meinung in  einem Freien Kopf    | Gegen Zensur | Gegen Krieg  =
_ _ O
 f=C3=BCr einen Freien Staat voll Freier B=C3=BCrger"  | im Internet! |   i=
m Irak!   O O O
ret =3D do_actions((curr | FREE_SPEECH) & ~(NEW_COPYRIGHT_LAW | DRM | TCPA)=
);

--qa1NXTiqN6KSzHv0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFEJrFMHb1edYOZ4bsRAgJWAJ0UmyyPdwnFhjjbBRPnIr/EFYujxQCfWO9/
MGJ0ZDiE7pUj6ecikUKG2N0=
=lxzA
-----END PGP SIGNATURE-----

--qa1NXTiqN6KSzHv0--
