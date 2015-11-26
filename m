From: Mark Brown <broonie@kernel.org>
Subject: Re: next-20151126 build: 3 failures 15 warnings (next-20151126)
Date: Thu, 26 Nov 2015 13:22:28 +0000
Message-ID: <20151126132228.GG1929@sirena.org.uk>
References: <E1a1sVV-00079q-My@optimist>
 <20151126121551.GE1929@sirena.org.uk>
 <87y4dllysz.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="ZOBTspFzEMOlPevk"
Cc: kernel-build-reports@lists.linaro.org,
	linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
	ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:49805 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbbKZNWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 08:22:38 -0500
Content-Disposition: inline
In-Reply-To: <87y4dllysz.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ZOBTspFzEMOlPevk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Nov 26, 2015 at 02:39:40PM +0200, Kalle Valo wrote:
> Mark Brown <broonie@kernel.org> writes:

> > It looks like this was somehow triggered as part of the reorganisation
> > of the WiFi directory structure.

> This is surprising and also worrying, any ideas why? It would be good to
> understand the root cause in case there's a bug in wireless drivers
> directory reorganisation.

No, I didn't make much effort to check though since the use of ifdef was
clearly a bug waiting to happen anyway, I was more surprised it worked
at all than anything.

--ZOBTspFzEMOlPevk
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWVweTAAoJECTWi3JdVIfQ1KgH/RBdqvEUc+9LSwYI0LHtPzfW
BxmFqs8xqr81JBpmBXi3u8Pqog+0xWrLZefsIssfDRfO3t1IcA0tkk9SuSDkjCsv
sKe960Bxa/1yBPnP67/GuNWNc5iOkE1y5BVTa10PKxs9Be77oZAZEANCMwaxwWeo
FpUaSbH8UcZ+lx5yT10mqAIEK1HWlXiRuZNrM/AxV9/0Y2lmjNBM8CEY9wMfBn+E
vEszFh9SAAbUMczh6j3O0xM9OF+qnZVfTnrPEcE7a4l1Y2IzKBaU/sRJZ644fYnJ
T469/8UtKr1/2kTGFil1s7j2kJ9rr0chMdipGP6bqiE8pUtFVAsGuj8mIX34090=
=+mvw
-----END PGP SIGNATURE-----

--ZOBTspFzEMOlPevk--
