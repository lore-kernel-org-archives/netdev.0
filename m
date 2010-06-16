From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build warnings after merge of the net tree
Date: Wed, 16 Jun 2010 16:30:48 +1000
Message-ID: <20100616163048.f72345c7.sfr@canb.auug.org.au>
References: <20100616133854.1bbbbb37.sfr@canb.auug.org.au>
	<20100615.215212.214211994.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__16_Jun_2010_16_30_48_+1000_+er/GVaxO2Thwcku"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100615.215212.214211994.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__16_Jun_2010_16_30_48_+1000_+er/GVaxO2Thwcku
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Tue, 15 Jun 2010 21:52:12 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> I've commited the patch below to deal with this, thanks for the report.

Thanks.

> There's some pre-existing warnings someone will need to deal with at
> some point:
>=20
> drivers/usb/gadget/rndis.c: whole file: warning: coding style is bolixed

:-)

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__16_Jun_2010_16_30_48_+1000_+er/GVaxO2Thwcku
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkwYb5gACgkQjjKRsyhoI8zAagCfSiACMgT3znDDo3zHjcbpY9B2
FCkAnRom+lesCiC4AgaVR0jJDHHDsROX
=EG3p
-----END PGP SIGNATURE-----

--Signature=_Wed__16_Jun_2010_16_30_48_+1000_+er/GVaxO2Thwcku--
