From: Mark Brown <broonie@kernel.org>
Subject: Re: arm64 allmodconfig failures in nft_reject_bridge.c
Date: Thu, 13 Nov 2014 23:51:52 +0000
Message-ID: <20141113235152.GR3815@sirena.org.uk>
References: <20141113114357.GA7857@salvia>
 <20141113.143513.785778562781935404.davem@davemloft.net>
 <20141113194752.GQ3815@sirena.org.uk>
 <20141113.152353.548265176661091467.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZAr10/UugL07XvY7"
Cc: pablo@netfilter.org, linux@roeck-us.net, kaber@trash.net,
	kadlec@blackhole.kfki.hu, stephen@networkplumber.org,
	linaro-kernel@lists.linaro.org,
	kernel-build-reports@lists.linaro.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:37373 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934400AbaKMXxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 18:53:40 -0500
Content-Disposition: inline
In-Reply-To: <20141113.152353.548265176661091467.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ZAr10/UugL07XvY7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Nov 13, 2014 at 03:23:53PM -0500, David Miller wrote:
> Date: Thu, 13 Nov 2014 19:47:52 +0000

> > On Thu, Nov 13, 2014 at 02:35:13PM -0500, David Miller wrote:

> >> I hold changes in my tree for a week or more, because I want them to
> >> "cook" there before they go to Linus.

> > Hrm.  Guess there must've been some other change in -next that pulled
> > the header in implicitly here :(

> -next pulls in my 'net' tree, so got the fix.

Right, but we didn't see the problem before you sent the tree with the
problematic patch to Linus - we didn't detect it in -next.

--ZAr10/UugL07XvY7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBAgAGBQJUZUQXAAoJECTWi3JdVIfQ3OcH/Ax8XGlpjGf74neFu7BW2r8p
FE38FVlrw1l6w0HpbyhgSgk+peB8yPlyMAmhhiOrPOt8YsN05t6fzixqENZUdrfN
a+eY2HIxkgoWY4DbofrFG2Fmg7exkfrUs5QHh9wrSIpFyXKz8gMbhEZyX0a64yxZ
zfIFu1XaWBZdTS+kpY/yxXsQoa84tCJlXG1CkpHc/V81Q6Ieiwxn5ARb4UNnja1y
cSdvaSkrMVydhgRFngqPc3H11/bb8BoWTgwassfFxUCX5OocGGGQBsaHY2PwPRI1
mY/jdgmhPu946qelwGWO2mqvEpZVpNO3ZiFcaDNwWZi4QwUlwu6cp4vsIzjELUA=
=dbJv
-----END PGP SIGNATURE-----

--ZAr10/UugL07XvY7--
