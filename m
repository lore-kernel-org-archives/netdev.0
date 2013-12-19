From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: pull request: linux-firmware: update cxgb4 firmware
Date: Thu, 19 Dec 2013 10:31:44 +0000
Message-ID: <1387449104.21926.39.camel@deadeye.wl.decadent.org.uk>
References: <20131215193220.GA7536@hariprasad-pc>
	 <1387152449.2803.3.camel@deadeye.wl.decadent.org.uk>
	 <20131216014537.GA8008@hariprasad-pc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-rT+GqUTopj+t7w41YTJD"
Cc: David Woodhouse <dwmw2@infradead.org>,
	netdev <netdev@vger.kernel.org>
To: Hariprasad S <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46944 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750875Ab3LSKcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 05:32:07 -0500
In-Reply-To: <20131216014537.GA8008@hariprasad-pc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-rT+GqUTopj+t7w41YTJD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-12-16 at 07:15 +0530, Hariprasad S wrote:
> On Mon, Dec 16, 2013 at 00:07:29 +0000, Ben Hutchings wrote:
> > On Mon, 2013-12-16 at 01:02 +0530, Hariprasad S wrote:
> > > Hi,
> > >=20
> > > Can you please pull from the following URL?
> > >     git://git.chelsio.net/pub/git/linux-firmware.git for-upstream
> > >=20
> > > The following changes since commit 7d0c7a8cfd78388d90cc784a185b19dcbd=
bce824:
> > >   Ben Hutchings (1):
> > >           Merge branch 'wilink4' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/balbi/linux-firmware
> > >=20
> > > are available in the git repository at:
> > >=20
> > >   git://git.chelsio.net/pub/git/linux-firmware.git for-upstream
> >=20
> > I'm no longer able to pull from this repository.  Depending on whether =
I
> > use my cellular data or home DSL connection it fails with either:
> >=20
> > $ git fetch git://git.chelsio.net/pub/git/linux-firmware.git for-upstre=
am
> > fatal: Could not read from remote repository.
> >=20
> > Please make sure you have the correct access rights
> > and the repository exists.
> >=20
> > or:
> >=20
> > $ git fetch git://git.chelsio.net/pub/git/linux-firmware.git for-upstre=
am
> > fatal: unable to connect to git.chelsio.net:
> > git.chelsio.net[0: 67.207.112.37]: errno=3DConnection refused
> >=20
> > Ben.
> Hi Ben,
>=20
> Sincere apologies. My bad again. Can you try now?

Pulled, thanks.

Ben.

>=20
> Thanks,
> Hari
> >=20
> > > Hariprasad Shenai (1):
> > >     cxgb4: Updated T4 firmware, add T5 firmware
> > >=20
> > >  WHENCE                  |    8 +++++---
> > >  cxgb4/t4fw-1.6.2.0.bin  |  Bin 431616 -> 0 bytes
> > >  cxgb4/t4fw-1.9.23.0.bin |  Bin 0 -> 486912 bytes
> > >  cxgb4/t4fw.bin          |    2 +-
> > >  cxgb4/t5fw-1.9.23.0.bin |  Bin 0 -> 481280 bytes
> > >  cxgb4/t5fw.bin          |    1 +
> > >  6 files changed, 7 insertions(+), 4 deletions(-)
> > >  delete mode 100644 cxgb4/t4fw-1.6.2.0.bin
> > >  create mode 100644 cxgb4/t4fw-1.9.23.0.bin
> > >  create mode 100644 cxgb4/t5fw-1.9.23.0.bin
> > >  create mode 120000 cxgb4/t5fw.bin
> > >=20
> > > Thanks,
> > > Hariprasad Shenai
> >=20
> > --=20
> > Ben Hutchings
> > Lowery's Law:
> >              If it jams, force it. If it breaks, it needed replacing an=
yway.
>=20
>=20

--=20
Ben Hutchings
It is easier to write an incorrect program than to understand a correct one=
.

--=-rT+GqUTopj+t7w41YTJD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUrLLEOe/yOyVhhEJAQp8XRAAm0XjEytG7zdjtooLiTLSBjZZ7U5QCnov
+P+3Z0S0dEnPjMlK0dFduEeZXqbGJeE+H3xZ6/SOvf2edvD6+pBiqr18QOpDZRJR
S/FjxfuS7YvYWg9jshMNQNKZDt8DK7aR/DGBn4pqxPlWWKqXbNRNbnE0HI0jxO9p
IdAnv6+ofLcOhcR529KMFNr/ecmmIOnP4BuZPeN4B0QtmVMsx6MbAh3zOamYypgo
2RuKI8hDSp6va13ES8bQcmvqzedXe94z8FeT2XSKDYRQbt5KIXlGPHmC+Ezuk7uo
xr0B5a/b/0VPE5LOk+oEFWA4TnqnCRX8eH//LORcG2LXuBJ0kllLvTL8MaRISyST
vlQ4TBeKVOn+xwJM/CjK4Czh2XmvZgEFQmg9fsQpmPYaF+by7BRA1ClMII5cXHEZ
WvtN68dSkJhdo1QC3lXREeDfgEZII178xI6kYQdcQPU82CSLNFPtIALSVtWnCYrq
nmpNMcK8kiX7f6106FmnqibpcKdQoXW/l9Mi8AYeTyYXyMWWnlSDjMOYFxFxybj9
uAtgelu0GhiB4Yi8tIRsjc+IHcE28JPoQViUhwHxOb92/l8Kyjp7zPhmCrub0CeH
I9YaBO6WYodwgmX5AsrL9Ixx2j0uGeAXaNCeLFs1NVtMj6RIexBKtdfW9b8gUBvf
EEYk7cXSX7w=
=diJ3
-----END PGP SIGNATURE-----

--=-rT+GqUTopj+t7w41YTJD--
