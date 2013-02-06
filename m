From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: [PATCH] batman-adv: Remove unused variable
Date: Wed, 6 Feb 2013 20:55:57 +0100
Message-ID: <20130206195557.GC6008@ritirata.org>
References: <1360168661-16871-1-git-send-email-emilgoode@gmail.com>
 <20130206172234.GB6008@ritirata.org>
 <1360173353.22154.4.camel@debian>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="+nBD6E3TurpgldQp"
Cc: lindner_marek@yahoo.de, siwu@hrz.tu-chemnitz.de,
	davem@davemloft.net, b.a.t.m.a.n@lists.open-mesh.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Emil Goode <emilgoode@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:24749 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758107Ab3BFT4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 14:56:51 -0500
Content-Disposition: inline
In-Reply-To: <1360173353.22154.4.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--+nBD6E3TurpgldQp
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Emil,

On Wed, Feb 06, 2013 at 06:55:53 +0100, Emil Goode wrote:
> Hi Antonio,
>=20
> The commit ed242d01 is in the linux-next tree and my patch depends on
> that commit.
>=20

Yes, you are right. I was not aware of this commit, because the author
did not CC us (neither netdev) even if he changed the code we maintain.

As far as I can see that commit is in linux-next only.
Therefore it must be applied there.

However, I'd like you to change the commit message and write the full hash =
of
the commit you are referring to and its subject ("LIKE THIS"). This would m=
ake
it easier to find it.


Regards,

> Best regards, Emil
>=20
> On Wed, 2013-02-06 at 18:22 +0100, Antonio Quartulli wrote:
> > Hi Emil,
> >=20
> > On Wed, Feb 06, 2013 at 05:37:41 +0100, Emil Goode wrote:
> > > The commit ed242d01 removed a node parameter from iterators.
> > > This patch removes a hlist_node struct that is no longer used.
> > >=20
> > > Sparse gives a warning:
> > >=20
> > > net/batman-adv/originator.c:411:21: warning:
> > > 	unused variable =E2=80=98node_tmp=E2=80=99 [-Wunused-variable]
> > >=20
> > > Signed-off-by: Emil Goode <emilgoode@gmail.com>
> >=20
> > On which tree did you base your patch?
> > I cannot find the commit you are referring to (ed242d01) and the patch =
does not
> > apply (neither on net nor net-next).
> >=20
> > Other than that the variable is used a couple of lines below (in the co=
de we
> > have)...
> >=20
> > Regards,
> >=20
>=20
>=20

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--+nBD6E3TurpgldQp
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRErVNAAoJEADl0hg6qKeO70sP+QGBVPOnKtLXmv6oTINvN3d/
4v0tQwBtISlvGb5LUOy/bvXX/sQOk/T6XfRSC617pIvF5Xp4+2eZpPV9JfXTw5Mg
FSG7PDHuWURSkTnQGsgQnEdBa4aVPYTDmKtGMdSe8QXnUGEwPdgZONTq1wxTrHyB
E0ii2G63BRZKmnwFbuga71whoKNfaf0O6kU8EmSQeVPml3TB5Qg0meqBFgBU73TL
KrAHbMlOWjska+VrPE/yEpfAdRJclvwxPn9ELhMPyf2jbAbik2cWHXLQTjJWkzpb
2S2R0YomgsYflIZo0NJkpnCXQOI4yqzlfufn494SiOcc65AB3J8uCTPgTLfnUhYz
QVquuy3lfQzoaoB/eGfjZUWXnrkiK5Sf+zEBMfobZMP5OS5+Lhx0dmr3BE1km6GV
ZNvoJcl04ANF4snVBpGHz8e4T0ihbThJMBmjTlBnBuIo6gzp7McGWmc7rj2u2PNV
Al1nXQTws0I2eDgldIKVJiUM3J0+F89N4axS52GyxtrU8ROcx9cBVAfe19Up+S8L
gAq95umyJZhO/OVbk94Zjf2BpU5JLIH/j/nysLfbQkfcvkidtb1r+B47RcL957ty
AjaIhIurwX+Ji+5NnoSvt/Cqmjk6kpFMyWdB9ahja3+bT8VfUGcV1MoiQjEJENkW
r/zeYtay3MWysE/8PbuE
=Qz3Y
-----END PGP SIGNATURE-----

--+nBD6E3TurpgldQp--
