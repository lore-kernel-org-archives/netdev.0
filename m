From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build warnings after merge of the net tree
Date: Wed, 1 Sep 2010 11:25:01 +1000
Message-ID: <20100901112501.570e06a1.sfr@canb.auug.org.au>
References: <20100831115508.078eb2fa.sfr@canb.auug.org.au>
	<20100830.215641.71568585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__1_Sep_2010_11_25_01_+1000_I2_Brd3JCOGWyPtW"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, peppe.cavallaro@st.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100830.215641.71568585.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__1_Sep_2010_11_25_01_+1000_I2_Brd3JCOGWyPtW
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Mon, 30 Aug 2010 21:56:41 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> I've checked the following into net-next-2.6 to combat-this (see,
> proactively fixing warnings in code I'm more or less responsible for
> instead of letting the issue rot for 2 months :-):

Thanks for that :-)

However, I missed one yesterday ...

drivers/net/stmmac/dwmac100_core.c: In function 'dwmac100_dump_mac_regs':
drivers/net/stmmac/dwmac100_core.c:47: warning: cast from pointer to intege=
r of different size

Sorry about that
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__1_Sep_2010_11_25_01_+1000_I2_Brd3JCOGWyPtW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMfatuAAoJEDMEi1NhKgbsxWQIAJD9mN67oaIYUnAM0WgicMG3
GNRUEZIhZx3+tAcY+c48R6e3N1OmCtDUT5m4zFZtnn1IYKvyhyZTQyNK3eZ8OlDB
DZTruCDvw5Ncd9Fezk6rPGo/9xIMEgzFLFv8A8AQ8lSrEWyqju//b7NRhTVIDt9x
c1AP9WWqeUeGRX+KeZX90MPyvqH00JZH/UEYhPIi7DFkEQmjGFBeIZlFc6Nh+oBq
+X3YQFmcXpWvf6EV+RKPJmPE6uj8qG3rL5qt1Us8okFAec6gX1g5sdhDjIYa/tnl
MxE8JJY14nCbj4ldd+JMiY8RkNHMAb8j+A7c+E/nWDY3NMXLTFCSzmAnoHPcU5M=
=Zwq/
-----END PGP SIGNATURE-----

--Signature=_Wed__1_Sep_2010_11_25_01_+1000_I2_Brd3JCOGWyPtW--
