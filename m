From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [GIT] Networking
Date: Thu, 31 Aug 2017 08:52:04 +0200
Message-ID: <20170831065204.GA17812@amd>
References: <87pobdt8qc.fsf@kamboji.qca.qualcomm.com>
 <20170830.101143.2305098064824357647.davem@davemloft.net>
 <87val5rmh8.fsf@kamboji.qca.qualcomm.com>
 <20170830.105447.125174575140677062.davem@davemloft.net>
 <87fuc8s5v9.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="IJpNTDwzlM2Ie8A6"
Cc: David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com,
        torvalds@linux-foundation.org, akpm@linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87fuc8s5v9.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu 2017-08-31 07:44:58, Kalle Valo wrote:
> David Miller <davem@davemloft.net> writes:
>=20
> > From: Kalle Valo <kvalo@codeaurora.org>
> > Date: Wed, 30 Aug 2017 20:31:31 +0300
> >
> >> AFAICS the bug was introduced by 9df86e2e702c6 back in 2010. If the bug
> >> has been there for 7 years so waiting for a few more weeks should not
> >> hurt.
> >
> > As a maintainer you have a right to handle bug fixing in that way, but
> > certainly that is not how I would handle this.
> >
> > It's easy to validate this fix, it's extremely unlikely to cause
> > a regression, and fixes a problem someone actually was able to
> > trigger.
> >
> > Deferring to -next only has the side effect of making people wait
> > longer for the fix.
>=20
> Yeah, you are right there. I did actually ponder which I tree should
> commit it back in July but due to various reasons decided differently.

Can we still get the fix to v4.13-final? :-).

Thanks,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--IJpNTDwzlM2Ie8A6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmnshQACgkQMOfwapXb+vJNsgCfX036Hgk1RrEOFRJjB95fe7f/
0n0AoJ7IEtEiYnyhR2NdHwwsBkjUmOXg
=AwV2
-----END PGP SIGNATURE-----

--IJpNTDwzlM2Ie8A6--
