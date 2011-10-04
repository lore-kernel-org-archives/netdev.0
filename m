From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the akpm tree
Date: Tue, 4 Oct 2011 18:44:19 +1100
Message-ID: <20111004184419.80cb1cc4cb47e6bce83bff2d@canb.auug.org.au>
References: <20110930153255.6e3a0d6dc7758b7fb5561fc6@canb.auug.org.au>
	<20110929230226.5fed4095.akpm00@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__4_Oct_2011_18_44_19_+1100_zMMuwhx7YIvjppg1"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stephen Boyd <sboyd@codeaurora.org>,
	Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Andrew Morton <akpm00@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110929230226.5fed4095.akpm00@gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__4_Oct_2011_18_44_19_+1100_zMMuwhx7YIvjppg1
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Thu, 29 Sep 2011 23:02:26 -0700 Andrew Morton <akpm00@gmail.com> wrote:
>
> > Caused by commit 15e19cbbbf2a ("x86: implement strict user copy checks
> > for x86_64") when built with gcc 4.6.0.  This does not fail when built
> > with 4.5.2.
>=20
> That patch is a PITA.  I've been waiting for some saviour to come along
> and fix all the warnings it emits before proceeding with it.  As I am
> apparently saviourless I shall hide that patch from the mm->linux-next
> drop, so only I get to suffer its effects.

OK, I have dropped that commit from linux-next.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__4_Oct_2011_18_44_19_+1100_zMMuwhx7YIvjppg1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOirlTAAoJEECxmPOUX5FELkIP/14Z3Vr/HvL3LtNnwdf1rW7g
sbZPWlJAw7yYgLfELTIbuZCHguqfJ02WESGyYHc+RXRFysCf0VTJ98VXCaufiSNu
Oea3nH/+aq6QubLHIRmO4Q90UD0b3aTy/bUOVJF5ynRahPkKHiDieSolbY69/AN0
70+6l9yV3dsVJDkH0PpbLENCnl0pRgi3suBkcpQv5iyXSGnJKHBH5Ku6KdjH6cXy
UGZvjMrhnBAcx4I63ONpfcfbAXFow+PR84e/gtXK+Zy0Rx72CRX/nrQgmJTfPG1k
F6VNbWBteqd8EbzxTFCIDTgvdjblfDf+eBgNPDijnVa2oWSstP6EHdYG7CPXNvAD
r2yadXOWdkO/aseMIvZjs/G8pH2iGfIA1+srvNYkVORMGyC/C1NXxoigJ+PUa/3A
GfH8Dsna7lH6JcXiPL0n2rK2sFxYtCcd1J9j+3s88P9rbcOhJf1RCh30WMI20Zfj
lNGWc4+p5WxkMtIjsViAZzHTer1Hu9yjo702TATjto1f/SyZ0Qwk8vVSU/RrFklP
eK6Fkw9ISrc3gIUqqtKhNOEA+Mas7ud7cag/keLXGFJ0+fo0WUWedcjdpBE4+H5s
GNeHDnUSN1F3bRHz/uvLpv9oKf0f/gKBUImFWeQR9jxiC1VLEiuJ2PgB4vb25uBJ
BmY5pYkIdKc5lJE76mDR
=xqD/
-----END PGP SIGNATURE-----

--Signature=_Tue__4_Oct_2011_18_44_19_+1100_zMMuwhx7YIvjppg1--
