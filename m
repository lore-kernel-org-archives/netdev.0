From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: Open hardware wireless cards
Date: Wed, 5 Jan 2005 15:36:45 -0500
Message-ID: <20050105203645.GO5159@ruslug.rutgers.edu>
References: <20050105200526.GL5159@ruslug.rutgers.edu>
	<Pine.LNX.4.61.0501052017380.5818@rivendell.nexusuk.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1055570283=="
Cc: Netdev <netdev@oss.sgi.com>,
	Jean Tourrilhes <jt@bougret.hpl.hp.com>,
	"Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
	Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	prism54-users@prism54.org, prism54-devel@prism54.org
Return-path: <prism54-users-bounces@prism54.org>
To: Steve Hill <steve@nexusuk.org>
In-Reply-To: <Pine.LNX.4.61.0501052017380.5818@rivendell.nexusuk.org>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-users>,
	<mailto:prism54-users-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-users>
List-Post: <mailto:prism54-users@prism54.org>
List-Help: <mailto:prism54-users-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-users>,
	<mailto:prism54-users-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Sender: prism54-users-bounces@prism54.org
Errors-To: prism54-users-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============1055570283==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Il7n/DHsA0sMLmDu"
Content-Disposition: inline


--Il7n/DHsA0sMLmDu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 05, 2005 at 08:22:10PM +0000, Steve Hill wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>=20
> On Wed, 5 Jan 2005, Luis R. Rodriguez wrote:
>=20
> >What I think we probably will have to do is just work torwards seeing if
> >we can come up with our own open wireless hardware. I know there was
> >a recent thread on lkml about an open video card -- anyone know where
> >that ended up?
>=20
> This may be a silly point, but there *was* good 802.11g hardware availabl=
e=20
> which worked well with the fully open drivers.=20

Yes, that would be the Full MAC prism chipsets with the linux prism54 drive=
r,
which I help maintain.

> I presume the=20
> manufacturers are moving to the "softmac" design instead because (for=20
> them) it is cheaper.

That is correct. They have already moved to the Softmac design and
you're lucky if you can buy FullMAC chipsets in stores now.

> However, the point is that the working designs are=20
> already there and it may be that buying the existing design which is bein=
g=20
> phased out is cheaper for the FOSS community than developing a whole new=
=20
> open device.

Definitely, I agree. Anyone have an idea of how much buying a wireless
chipset design may cost?

> Maybe it would be possible to convince one of the manufacturers that it's=
=20
> worth their while producing the older design hardware - if there is a=20
> single manufacturer who is making more or less the only hardware that is=
=20
> guaranteed to work under Linux there is probably quite a market for them.

I think they made the move because of economics as you mentioned
earlier. Under the current circumstances, I find it hard to be able to
Convince Conexant, for example, to start selling FullMAC chipsets again.

AFAICT the FullMAC chipsets have reached the END OF LIFE period.

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--Il7n/DHsA0sMLmDu
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFB3E/dat1JN+IKUl4RAn+zAJ9Nqm7B2/Z/4ouMrwSdYqjNQlSLRQCfdWtT
Zum49MFe0zuSx+3O2yHHpKE=
=uXsP
-----END PGP SIGNATURE-----

--Il7n/DHsA0sMLmDu--

--===============1055570283==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-users mailing list
Prism54-users@prism54.org
http://prism54.org/mailman/listinfo/prism54-users

--===============1055570283==--
