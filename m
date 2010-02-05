From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Fri, 5 Feb 2010 22:49:11 +1100
Message-ID: <20100205224911.d6b089e5.sfr@canb.auug.org.au>
References: <20100205165059.0b5d5363.sfr@canb.auug.org.au>
	<20100204.223255.146893399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__5_Feb_2010_22_49_11_+1100_KU75_Hlq_bBdonsn"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, nicholasx.d.nunley@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100204.223255.146893399.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__5_Feb_2010_22_49_11_+1100_KU75_Hlq_bBdonsn
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Thu, 04 Feb 2010 22:32:55 -0800 (PST) David Miller <davem@davemloft.net>=
 wrote:
>
> Damn namespace pollution, this is one of a zillion reasons
> I prefer drivers are written in one sorce file, then people
> can name their functions however they like and they're all
> marked static so it doesn't cause problems like this.
>=20
> I've fixed it up as follows in net-next-2.6

Looks good, thanks.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__5_Feb_2010_22_49_11_+1100_KU75_Hlq_bBdonsn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAktsBbcACgkQjjKRsyhoI8yI6ACdEU60Y5WDizRAvjbVKhHGw6Vv
gCcAnRephHf7qNNaGiLGakB2s2KGKRTu
=qRnG
-----END PGP SIGNATURE-----

--Signature=_Fri__5_Feb_2010_22_49_11_+1100_KU75_Hlq_bBdonsn--
