From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: net tree build warning
Date: Fri, 22 May 2009 18:20:24 +1000
Message-ID: <20090522182024.cfe48be4.sfr@canb.auug.org.au>
References: <20090522151642.e79e22ee.sfr@canb.auug.org.au>
	<20090521.233038.195647453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__22_May_2009_18_20_24_+1000_qmXu/iGOrEb1uMgG"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	nhorman@tuxdriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090521.233038.195647453.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__22_May_2009_18_20_24_+1000_qmXu/iGOrEb1uMgG
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Thu, 21 May 2009 23:30:38 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> I just pushed the following to fix this:
>=20
> net: Fix arg to trace_napi_poll() in netpoll.

Thanks. I remerged the net tree at the end of linux-next today in case
anyone was doing any testing over the weekend.=20

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__22_May_2009_18_20_24_+1000_qmXu/iGOrEb1uMgG
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkoWYEgACgkQjjKRsyhoI8yzzwCggJcCGwwm6y/uN97ocrSSazmC
fvEAnR7Bnl/DO72V5yTvZhS3bWOT9kNg
=XhrU
-----END PGP SIGNATURE-----

--Signature=_Fri__22_May_2009_18_20_24_+1000_qmXu/iGOrEb1uMgG--
