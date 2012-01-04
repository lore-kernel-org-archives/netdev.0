From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless 2012-01-04 #2
Date: Wed, 4 Jan 2012 11:57:52 -0500
Message-ID: <20120104165752.GH2540@tuxdriver.com>
References: <20120104164339.GG2540@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="J5MfuwkIyy7RmF4Q"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120104164339.GG2540@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--J5MfuwkIyy7RmF4Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 04, 2012 at 11:43:40AM -0500, John W. Linville wrote:
> Dave,
>=20
> Here are a handful of straggler wireless fixes for 3.2.  Included is
> a NULL pointer fix for mwifiex, a regression fix for handling rx
> header lengths for differnt b43 firmwares in PIO mode, a revert of
> a one-liner for Bluetooth HCI that was causing uncomfortable delays
> during resume, and an ath9k fix for a panic when running in AP mode
> with aggregation disabled.
>=20
> The Bluetooth fix is a one-liner change of a delay value.  The mwifiex,
> b43, and ath9k fixes are relatively small and isolated to their
> respective drivers.
>=20
> Please let me know if there are problems!
>=20
> John
>=20
> ---
>=20
> The following changes since commit 405cc2736527bd506fd8f652308b03b2c8a1e8=
b9:
>=20
>   fix CAN MAINTAINERS SCM tree type (2012-01-03 14:57:43 -0500)
>=20
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for=
-davem

The top of the tree here is commit d8f46ff11081f03b09efe82245a3257bab6bf60e.

Thanks,

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--J5MfuwkIyy7RmF4Q
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPBIUPAAoJEJctW/TcYTgGDbAQAIzBwlebXC7xi4l+JYIth6Qd
hdztsJoloFnetiSOVh9iyZgfOfKltweWZgPtjSTtyvxrNWIzB2aS+IvFYHYOduBc
VSBRQWT6CTBrnoCvTrIATnYXcmiIkQa8W1ylVPLujUnrcSp40hAb+hps25SWRvPg
FSnhlCIE5D55sxshUgNG9qmJaJrsivbjrKeDiKSwzivC9K2GZCHubqd9suIer7fZ
AwiK20ayJ9T3jS68qu2H3BDeZuTni2W57pENHe+UFF2nE3Bytyhx0+A6hFx5fapu
1x2V/BxUWL8v/QoXutImOsyYG22DuDfzuOd7/4A53W9Z2mO0al4Qa/TKCqoUrTBH
/g/NlDbUdFXzU/o8a9MJEzX0f8vmXhqJ9xFD2RxlVQIikYKXFrpTMOapuXMWR3Eo
h87nxxIOfd7dwImHbJxo5zs2jdkp08fdRemozWdsLBsmi96mumNzXQaLE3fnvv8K
PxJboyZWs8E4z/bamBgM7LjQDXcKYtys36W+/UkI0ZT0FkupS77jVEJIg+ww/ySC
gMyU9b84qroeunHhISAZK3V3VRGgEf9TnxmeeeGRANx15ALl5LyEopuEO64Cp+Bm
bn43sgL5K9XU1u4x0AvSvwf3hTqAYPrlAL2Pau9ClJc1IzgSwG9eI+TnOip55W3w
+2kHbM6UJ7spUKrVkl6y
=bAk9
-----END PGP SIGNATURE-----

--J5MfuwkIyy7RmF4Q--
