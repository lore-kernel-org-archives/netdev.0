From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: Re: [PATCH 20/33] net: Convert to devm_ioremap_resource()
Date: Tue, 22 Jan 2013 14:09:57 +0100
Message-ID: <20130122130957.GA18165@avionic-0098.adnet.avionic-design.de>
References: <1358762966-20791-1-git-send-email-thierry.reding@avionic-design.de>
 <20130121.152913.1377695352860141642.davem@davemloft.net>
 <20130122065629.GA14523@avionic-0098.adnet.avionic-design.de>
 <201301221303.06785.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/04w6evG8XlLl3ft"
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, dmitry.torokhov@gmail.com,
	w.sang@pengutronix.de, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:57314 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726Ab3AVNKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 08:10:07 -0500
Content-Disposition: inline
In-Reply-To: <201301221303.06785.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 22, 2013 at 01:03:06PM +0000, Arnd Bergmann wrote:
> On Tuesday 22 January 2013, Thierry Reding wrote:
> > I planned to do so initially, but that yielded a Cc list of 156 people
> > and mailing lists, which I thought wasn't going to go down so well
> > either. In general I like Cc'ing everyone concerned on all patches of
> > the series, specifically for reasons of context. Some people have been
> > annoyed when I did so. Still, for small series where only a few dozen
> > people are concerned that seems to me to be the best way. But 156 email
> > addresses is a different story.
> >=20
> > Either you add to many people or you don't add enough. Where do we draw
> > the line?
>=20
> I've had the same problem a couple of times. The best compromise seems
> to be to Cc only the top-level subsystem maintainers and mailing lists
> on the first email.

Even that would have been about 50 addresses IIRC. But perhaps that's
still the best compromise to avoid any confusion.

Thierry

--/04w6evG8XlLl3ft
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQ/o+lAAoJEN0jrNd/PrOhkwEP/ixTv70eEqwHXX28nnkbRwqv
uZFK5yqSiHJGlLIxyE7SeVPluQTt7ZLKrf6Zc/xhztHQ8FrRvLPvyqMoZuxOHDyQ
jZITotuDlJKXZG128W/x+avJlIgq5Lmai2KoHp21QcBRkQyxTKgD+0zosAHk26BM
oemmTTzagN87xnARIgsGteXCuGk2qag7Qwaht/yU1KuBH0IomIHc1yQW/cvDGQ8y
aBmtp6ILsPZgRvrRfoD0ZtlixEw1tvkgU8YNizjsBZXHmXNUvNGeu9S1m71HtYN2
EZsDQvSjIOC9+d69eVp8PU4KFcQbeltmT9RTKbYuTBLXcMWlyJc6d5nTkYBtz51e
bIrxYqtikLMr9C7UNF5FtX0c6xeRWnfVRTtAff/iqo9GxnSWcQsTMJPCMNsON9Da
TIbGnzsfE/9c5i4oaqUcDoU21sD6Bweu6DPrP5RZYjApc0fTDbnSnmif6IRpoKhc
UE3pod75SRpxzks1p+W7hT/h4jYd+MWKRmh0IrMlHPMkr7RySBOynZtF6pbxwkAM
hVsC5qiZCPSl+6MyAfvThNNsyUkQ6eAxmgmN9OPNU6tUCu2DSrQqNIeuKIZKMiXj
I8+TcQlnJGGPQ5hFO+0Cjv2YPUUcNm1o2ndfb6FGPn3jm5UjBg3aLZYE0f7NXZQM
OnOHtzS8qS4Vdu2ElBnV
=b4+2
-----END PGP SIGNATURE-----

--/04w6evG8XlLl3ft--
