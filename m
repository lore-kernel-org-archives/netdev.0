From: Harald Welte <laforge@gnumonks.org>
Subject: Re: 2.6.8.1 IPv6 Routing Problem
Date: Sat, 25 Dec 2004 12:54:15 +0100
Message-ID: <20041225115415.GI24142@sunbeam.de.gnumonks.org>
References: <Pine.LNX.4.44.0409200806460.22679-100000@netcore.fi> <20040920.152012.114156249.yoshfuji@linux-ipv6.org> <20040921195752.015e3d1d.davem@davemloft.net> <20040922.120630.96674716.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="kGQlNN4Ir6FkfZg7"
Cc: davem@davemloft.net, pekkas@netcore.fi, netdev@oss.sgi.com,
        usagi-users@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040922.120630.96674716.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--kGQlNN4Ir6FkfZg7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Getting back to an ooooold thread...


On Wed, Sep 22, 2004 at 12:06:30PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ w=
rote:
> In article <20040921195752.015e3d1d.davem@davemloft.net> (at Tue, 21 Sep =
2004 19:57:52 -0700), "David S. Miller" <davem@davemloft.net> says:
>=20
> > On Mon, 20 Sep 2004 15:20:12 +0900 (JST)
> > YOSHIFUJI Hideaki / =1B$B5HF#1QL@=1B(B <yoshfuji@linux-ipv6.org> wrote:
> >=20
> > > This behavior lives for years (AFAIK),
> > > and we haven't got so many reports=20
> > > because people usually bring loopback device first.
> > >=20
> > > I think the following message will help people, anyway.
> >=20
> > If ipv6 has a dependency upon this, why doesn't it just
> > bring the device up itself at this moment if necessary?
>=20
> Okay, I'll make a patch for this.

As far as I can see (please correct me) no such patch was included so
far, at least with 2.6.10-rc3 I still have the old behaviour.

Could you please include the proposed printk-warning-patch until the
issue gets resolved?

Thanks!

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--kGQlNN4Ir6FkfZg7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBzVTnXaXGVTD0i/8RAnPVAKCMsgFcBs6mnznNGik38Tad4gDFaQCfRxvx
jefOfynXR/pSGzB0CYcEIsA=
=96sV
-----END PGP SIGNATURE-----

--kGQlNN4Ir6FkfZg7--
