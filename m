From: Mark Brown <broonie@kernel.org>
Subject: Re: arm64 allmodconfig failures in nft_reject_bridge.c
Date: Thu, 13 Nov 2014 12:51:28 +0000
Message-ID: <20141113125128.GH3815@sirena.org.uk>
References: <E1Xm8gR-0005nT-PY@debutante>
 <20141106104616.GU8509@sirena.org.uk>
 <20141112233738.GB3815@sirena.org.uk>
 <20141113113320.GF3815@sirena.org.uk>
 <20141113114357.GA7857@salvia>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="EIkFwwKGr1GxMZbQ"
Cc: "David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Stephen Hemminger <stephen@networkplumber.org>,
	linaro-kernel@lists.linaro.org,
	kernel-build-reports@lists.linaro.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141113114357.GA7857@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--EIkFwwKGr1GxMZbQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Nov 13, 2014 at 12:43:57PM +0100, Pablo Neira Ayuso wrote:

> I can see this in David's tree:

> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=c1207c049b204b0a96535dc5416aee331b51e0e1

> I think this was reported by when -rc4 was already out, so you'll see
> this by -rc5.

The fix predates -rc4 (sent on the 2nd, committed on the 3rd, -rc4 was
on the 9th), I'd been expecting to see it turn up there or shortly
after.

--EIkFwwKGr1GxMZbQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBAgAGBQJUZKlPAAoJECTWi3JdVIfQk0sH/3IOqCbsM3iqHZAQ2vrKQI/r
YXLMkRbS373mZq5f5SNzYGkjV8l9uGWzS7nw+r4DYj2cVygaxSu8vVFA1jKkPCuA
bv8SUPJduKKVQleEysxYgz3WwUxOiDCaD67aZJeR5qcHdZ0eaueFiDMqbTWxhkSJ
QVBZNMrGYGJrFo5pp1GNRqcVBtjO3rP52PH2On2e49IeEDNtBnngH1s4TNVQHmwK
Nz+ugckeEjYxFhqaB0GPK6HQxIzrlTEpaxtnmxGk3mogawW7OxKDc/L8tGK7+lCe
3QKs8SI8b2OBbnp2fW3oyohyekakUthuBjpQ6gmVfkLGW4AiqCZlYJrkCFjc8xw=
=bU/a
-----END PGP SIGNATURE-----

--EIkFwwKGr1GxMZbQ--
