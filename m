From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v2 3/3] sch_netem: replace magic numbers with
 enumerate in GE model
Date: Sun, 16 Feb 2014 12:44:30 +0000
Message-ID: <1392554670.15615.93.camel@deadeye.wl.decadent.org.uk>
References: <1392345043-12208-1-git-send-email-yangyingliang@huawei.com>
	 <1392345043-12208-4-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-8M0Rtb8uFBC2L1lqFNC8"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35844 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751477AbaBPMop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Feb 2014 07:44:45 -0500
In-Reply-To: <1392345043-12208-4-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-8M0Rtb8uFBC2L1lqFNC8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-02-14 at 10:30 +0800, Yang Yingliang wrote:
> Replace some magic numbers which describe states of GE model
> loss generator with enumerate.
[...]

The name GOOD_STATE should also be used in get_loss_clg() where
clgstate::state is initialised.

Ben.

--=20
Ben Hutchings
Any sufficiently advanced bug is indistinguishable from a feature.

--=-8M0Rtb8uFBC2L1lqFNC8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwCyrue/yOyVhhEJAQqLLBAAsv+d8d2zfVSxlGoFpBNG7Pe7j+k0ix4c
SGJlRvUKsxARu+q2172mBMLA+DErCuLc1eFq88ekXX0xUF+5Epme84RWwKgXOwsR
WCt5bKHNm1kaZb2gyDiyFOyBUmy4uIsWJM21iwFV7/HBBiWUZxL4j9VvbObcsKbH
UoZHJfs1GysPBtwE9rEcG5+OHPf4mFnKZGeAso9EcCM9/axJBEgVT2zXHcdiYUp9
yl5Sd6WiiPyYkFFtsBhVBJZlj5jx34I9ynPkEDjpoY0DyvS7Q5AKg0TtplXaM774
E4fvM051NINjktWGxvwFg0DvYqSgx3NK8XODYa8Pi8E4a8KNgyjbCbYD94FkC+C1
kQMU+mFmVSiSTCIEBNLiIQJya3iBk5kIDMSR8OqYedrViZgLPtuKgMzZyNTefF/K
oEsxjGNtLl4gYYOGqur5MS8kdTc8oUGvfaL8l+7Dedc+98fLCCfZK1B/fRwtKBKt
ifCtdpVj7Xc8WILuJKgb0uigDKI4fdWydehk9HGsoP5MKZMQaKNoynUM5xAk7oax
VS2UeXwbUkRGc2OOWqZ8QyZ+5qj1sLN7eEGwAiza2Rn9goGfi9YBF4HmaLlbSaGu
CqNcrmpzl4Y+SCuIuoJT6rzIJxiUHLt76aDW8CuQlPn5HczZ3r3aHTZODyOR32dj
i0Et3Sonheo=
=KNYG
-----END PGP SIGNATURE-----

--=-8M0Rtb8uFBC2L1lqFNC8--
