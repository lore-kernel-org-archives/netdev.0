From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH] net/core: Add VF link state control policy
Date: Tue, 10 Jun 2014 16:12:08 -0400
Message-ID: <1402431128.9149.8.camel@firewall.xsintricity.com>
References: <d040256cbe494908726bb1d05612f69cee4ff040.1402430365.git.dledford@redhat.com>
	 <539765F4.10506@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-YDur7GFuMxAUFYHFMp1I"
Cc: netdev@vger.kernel.org, Rony Efraim <ronye@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5938 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755048AbaFJUMY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2014 16:12:24 -0400
In-Reply-To: <539765F4.10506@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YDur7GFuMxAUFYHFMp1I
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-06-11 at 00:09 +0400, Sergei Shtylyov wrote:
> Hello.
>=20
> On 06/10/2014 11:59 PM, Doug Ledford wrote:
>=20
> > Commit 1d8faf48c7 added VF link state control to the netlink VF nested
>=20
>     Please also specify that commit's summary line in parens.

It was almost a carbon copy of my own commit summary:

(net/core: Add VF link state control)

>=20
> > structure, but failed to add a proper entry for the new structure into
> > the VF policy table.  Add the missing entry so the table and the actual
> > data copied into the netlink nested struct are in sync.
>=20
> > Signed-off-by: Doug Ledford <dledford@redhat.com>
>=20
> WBR, Sergei
>=20


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--=-YDur7GFuMxAUFYHFMp1I
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJTl2ahAAoJELgmozMOVy/dO6UP/ii77jj56BHPm+szWr1kqNaw
bASpDbWYNuydK08GrP4nyKGvjfBcZELC4HKsTDfLt8hkAKBLb8X1l2U3PJpFRQHu
hb1sLK1s23h5WhJPWcUgHKVZAlMDRy65KfDT9hpSWT0eZ512lgsNNlpTE3uFWnIc
HgYYmRjWiRk+u/9Miw98kXa8SsLzLyGV6EtIJTKRrtySHZGSCfbcHbTg9BF4EyM2
FE0qMYFLpMEcZXjs6qVa9fion5xkn+FsK1fbk+La/mNYGiWm2NvKyDA25TZAehHd
c5y9anF2wJXsPAj7FseK+JyKG+CotaQtSVxauWNs/WhLgJgFlGby9L/nxyThtTZV
sfKprXgruE11YTj/GoSiQGF/r9Tkm7fIyTyjO1NiBtjgOMZEI+bHXclJGqZfP9LR
iUKvDhO6Ytqbkf1oZZhfw651nR9vBHiHRfh/SKjaUsESpgloxAt8+7cStYdLK5QS
OUH4yd85hQFzxxfFl20mWtN8V/saY3tckchrDeWiMqWCdQ4+5yFquuw2SaNclC8a
87I4lgiDm0xW+yQ0+2U3yAd6/KLqqCi1ijBI8Mwcg5x3roBjB6VzcDSuOznRZuNM
h1TAjyzwNi136/5BIzESFJZ6qjJMK0IHQYaCday0UGWUGX7EWkgZyovSr3148nCB
QeAxH8DK976R54UD1pz2
=0T4B
-----END PGP SIGNATURE-----

--=-YDur7GFuMxAUFYHFMp1I--
