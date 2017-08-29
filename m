From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] Documentation: fix little inconsistencies
Date: Tue, 29 Aug 2017 22:34:11 +0200
Message-ID: <20170829203411.GA21650@amd>
References: <20170828094638.GA15378@amd>
 <20170828161707.GA4750@magnolia>
 <20170829072708.GA30643@amd>
 <20170829165057.GB4750@magnolia>
 <20170829130945.7603d035@lwn.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="mP3DRpeJDSE+ciuQ"
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
        tytso@mit.edu, linux-ext4@vger.kernel.org,
        Andrew Morton <akpm@osdl.org>
To: Jonathan Corbet <corbet@lwn.net>, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170829130945.7603d035@lwn.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--mP3DRpeJDSE+ciuQ
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue 2017-08-29 13:09:45, Jonathan Corbet wrote:
> On Tue, 29 Aug 2017 09:50:57 -0700
> "Darrick J. Wong" <darrick.wong@oracle.com> wrote:
>=20
> > > Anything wrong here? It is fixing extra '+' in the ascii art... =20
> >=20
> > There's nothing incorrect here, I merely thought it odd to send a fix
> > for networking documentation to the ext4 list, but not netdev?
>=20
> In fact, davem likes to handle networking documentation patches himself,
> so resending this one to netdev would be a good idea.

Its a typo in documentation, do we really need to waste any more time
with it? Dave, can you just ack it?

> > index 5e40e1f..6309e90 100644
> > --- a/Documentation/networking/switchdev.txt
> > +++ b/Documentation/networking/switchdev.txt
> > @@ -29,7 +29,7 @@ with SR-IOV or soft switches, such as OVS, are
> > possible.
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

Besides, if documentation fixes should go to Davem/netdev,
getmaintainer.pl should say so:

pavel@duo:/data/l/linux-n900$ scripts/get_maintainer.pl -f
Documentation/networking
Jonathan Corbet <corbet@lwn.net> (maintainer:DOCUMENTATION)
"David S. Miller" <davem@davemloft.net> (commit_signer:52/87=3D60%)
David Howells <dhowells@redhat.com>
(commit_signer:7/87=3D8%,authored:8/87=3D9%)
Florian Fainelli <f.fainelli@gmail.com> (commit_signer:6/87=3D7%)
Mauro Carvalho Chehab <mchehab@kernel.org>
(commit_signer:6/87=3D7%,authored:5/87=3D6%)
Yuchung Cheng <ycheng@google.com> (commit_signer:6/87=3D7%)
Hangbin Liu <liuhangbin@gmail.com> (authored:5/87=3D6%)
linux-doc@vger.kernel.org (open list:DOCUMENTATION)
linux-kernel@vger.kernel.org (open list)
pavel@duo:/data/l/linux-n900$

								=09
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--mP3DRpeJDSE+ciuQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmlz8MACgkQMOfwapXb+vJimQCeI6vmle5n1CyFX5yaANFCUcxT
xwkAoMJlUpRaZKZvlPuPdhfpMkoIH+6T
=k/QQ
-----END PGP SIGNATURE-----

--mP3DRpeJDSE+ciuQ--
