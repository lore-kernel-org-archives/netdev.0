From: Jan-Benedict Glaw <jbglaw@lug-owl.de>
Subject: Re: [RFC 2.6.10 1/22] xfrm: Add direction information to xfrm_state
Date: Thu, 30 Dec 2004 17:36:17 +0100
Message-ID: <20041230163617.GB2460@lug-owl.de>
References: <20041230035000.01@ori.thedillows.org> <20041230035000.10@ori.thedillows.org> <20041230094839.GX2460@lug-owl.de> <1104423409.23254.9.camel@dillow.idleaire.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5Wo9T3dGHPT+4OQz"
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Dillow <dave@thedillows.org>
Content-Disposition: inline
In-Reply-To: <1104423409.23254.9.camel@dillow.idleaire.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--5Wo9T3dGHPT+4OQz
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 2004-12-30 11:16:49 -0500, Dave Dillow <dave@thedillows.org>
wrote in message <1104423409.23254.9.camel@dillow.idleaire.com>:
> On Thu, 2004-12-30 at 04:48, Jan-Benedict Glaw wrote:
> > On Thu, 2004-12-30 03:48:34 -0500, David Dillow <dave@thedillows.org>
> > wrote in message <20041230035000.10@ori.thedillows.org>:
> > > +enum {
> > > +	XFRM_STATE_DIR_UNKNOWN,
> > > +	XFRM_STATE_DIR_IN,
> > > +	XFRM_STATE_DIR_OUT,
> > > +};
> >=20
> > Any specific reason to first define such a nice enum and then using int
> > in the struct?
>=20
> Just following the current style in net/xfrm.h, see xfrm_state.km.state
> and XFRM_STATE_*.

Hmmm... Maybe I'd prepare patches then :)

MfG, JBG

--=20
Jan-Benedict Glaw       jbglaw@lug-owl.de    . +49-172-7608481             =
_ O _
"Eine Freie Meinung in  einem Freien Kopf    | Gegen Zensur | Gegen Krieg  =
_ _ O
 fuer einen Freien Staat voll Freier B=C3=BCrger" | im Internet! |   im Ira=
k!   O O O
ret =3D do_actions((curr | FREE_SPEECH) & ~(NEW_COPYRIGHT_LAW | DRM | TCPA)=
);

--5Wo9T3dGHPT+4OQz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFB1C6BHb1edYOZ4bsRAraeAJ4kdi0KY9MbAavAWo1ZpQ8F7bnn3wCbBvjS
UD3Tby1J+v8hAYqL5uWkgrE=
=Vrl2
-----END PGP SIGNATURE-----

--5Wo9T3dGHPT+4OQz--
