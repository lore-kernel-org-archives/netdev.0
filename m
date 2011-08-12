From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: Question about the drivers movement (IBM_NEW_EMAC)
Date: Fri, 12 Aug 2011 12:54:02 +1000
Message-ID: <20110812125402.f54c52c09a18cb40ecc5489b@canb.auug.org.au>
References: <20110812120744.1912ca01ab4e76faaa93892c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__12_Aug_2011_12_54_02_+1000_8HytCwul1kD=4bjH"
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	<netdev@vger.kernel.org>, ppc-dev <linuxppc-dev@lists.ozlabs.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110812120744.1912ca01ab4e76faaa93892c@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__12_Aug_2011_12_54_02_+1000_8HytCwul1kD=4bjH
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

[just cc'ing linuxppc-dev mailing list]

On Fri, 12 Aug 2011 12:07:44 +1000 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> Hi Jeff,
>=20
> In commit 9aa328359545 ("ehea/ibm*: Move the IBM drivers") from Dave's
> net tree, you not only move the drivers around, but you change
> CONFIG_IBM_NEW_EMAC to CONFIG_IBM_EMAC.  Won't that mean that all the
> PowerPC configs that currently set CONFIG_IBM_NEW_EMAC to y will no
> longer build this driver?

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__12_Aug_2011_12_54_02_+1000_8HytCwul1kD=4bjH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJORJXKAAoJEDMEi1NhKgbs2FMH/AupNfIXYr5afODGIH4sSgNW
i6G8xTD5o2euiBLupdKnA6FeY9nxaGhWLJ7K9qpXPUyym5I4ptOONcLkOXvLx1c6
mJNgdzZp/Qp1py9T5cpdOaQRDA4iuohsLNbcq1pXbBZEMq8bDecZJIIP7knbGQtb
DZRmVPW2bJXvpTKfahQbuKujiJAi8bRtUxv4/o+BIVDI3bUdcv+/NJeAM1Rdfi4Q
8hohZ8eZsvFMHUR1Qnt69ci4hsDe/ewfzleWkz8wBz6TMIBORM0desgJiqAq135U
BtUD1fSW0zdoGYMVI5z7EIynKA4uJrsBiRYYfRz6oVT/HIiGegiQvMZsOXukqnA=
=QEju
-----END PGP SIGNATURE-----

--Signature=_Fri__12_Aug_2011_12_54_02_+1000_8HytCwul1kD=4bjH--
