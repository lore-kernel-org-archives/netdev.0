From: Andrey Rahmatullin <wrar@altlinux.org>
Subject: Re: via_rhine kernel crashes in 2.6.32
Date: Mon, 21 Dec 2009 17:36:48 +0500
Message-ID: <20091221123648.GC5269@wrars-comp.wrarsdomain>
References: <20091219111206.GA5307@wrars-comp.wrarsdomain>
 <20091220200343.GA5427@wrars-comp.wrarsdomain>
 <alpine.DEB.2.01.0912210352200.3483@bogon.housecafe.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="JWEK1jqKZ6MHAcjA"
Cc: LKML <linux-kernel@vger.kernel.org>, Roger Luethi <rl@hellgate.ch>,
	netdev@vger.kernel.org
To: Christian Kujau <lists@nerdbynature.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756726AbZLUMhM@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.01.0912210352200.3483@bogon.housecafe.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--JWEK1jqKZ6MHAcjA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 21, 2009 at 04:03:06AM -0800, Christian Kujau wrote:
> Wow, I had to rotate my laptop here. In you first posting [0] you said yo=
u=20
> "upgraded to .32" but had crashes in .30 too. What was the last working=
=20
> kernel?
It was 2.6.31, but as I've already said I'm not sure it was because of
kernel version alone.

> In the .jpgs one can see something along the lines of=20
> schedule_timeout, napi_disable, rhine_tx_timeout - the only patch I could=
=20
> find touching these things [1] altogether is rather old, from 2.6.24. Is=
=20
> 2.6.29 working for you?=20
Well, I can try some old versions.

--=20
WBR, wRAR (ALT Linux Team)

--JWEK1jqKZ6MHAcjA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBCAAGBQJLL2vfAAoJEOih81koZvPBIWQH/1mhgrqs4xdI9eyp3Tec5Q4s
GigXo6Mr+mLyCOkBZZI9eqeiQL0+bEsGKDQOgTwn4rRMaz8dUGv0T2dBZTdm03Ab
Nf7Ud4niI+GmKJxllWpdNcsNhoMqv4Ne+01feFsoXzmjf2Sfb/kCFTxlhXixglSI
qPaDBIK6JwvwqI62MsEA0MskpT5sMkaj0PuO2p41lV8V5SWiZv1BUDolxdu1+9bY
yf95HNr4w/89NSfqv0Nap/tplXpfeHg7lGrMLqnry7Jl1Genaggiwgz9dTiaiyMo
xK6+xMCd79W1vyWb1lStn+DsmDwg0Ha1w6UbbsadgT9upDZJ433g5klH7JgIraM=
=4Q1K
-----END PGP SIGNATURE-----

--JWEK1jqKZ6MHAcjA--
