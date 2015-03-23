From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v6 2/7] ixgbe: Add a new netdev op to
 allow/prevent a VF from querying an RSS info
Date: Mon, 23 Mar 2015 03:30:33 -0700
Message-ID: <1427106633.2577.159.camel@jtkirshe-mobl>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com>
	 <1427050887-19412-3-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-IdEfso3CxfPLKxjBEzJ2"
Cc: netdev@vger.kernel.org, avi@cloudius-systems.com,
	gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58470 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752033AbbCWKae (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2015 06:30:34 -0400
In-Reply-To: <1427050887-19412-3-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-IdEfso3CxfPLKxjBEzJ2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-03-22 at 21:01 +0200, Vlad Zolotarov wrote:
> Implements the new netdev op to allow user to enable/disable the
> ability
> of a specific VF to query its RSS Indirection Table and an RSS Hash
> Key.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  7 +++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 27
> ++++++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  2 ++
>  4 files changed, 37 insertions(+)

Thanks Vlad, I have applied your patch to my next-queue tree
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-IdEfso3CxfPLKxjBEzJ2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVD+tJAAoJEOVv75VaS+3OSmwP/RYMgx/kCIUU6N8iRVtNHS2z
IR0C1j9lUoiK27I0qoi/FrOXrjbRHX8TGZK8v+Ml9F+EsnDVvuz5Zq11cwlCXfkP
yLPYD+arISVC6d4Aed2iosXWsUo8AuKXyEQD7srAjX4fSJ8pSzvVBMLlOG38A6Sn
L42Agl/rpjhvfI7NPo1lujSXxrggyJGarKf1XKuYx6ZbhKK3/+5pRmDT+f4DEpyO
/dufGVJjepiQhEUCCQG+iC1A/gCt5qA6xH05qbweyrqrzLcHil2tQsikUWLWVJIc
YAYImmUFHVbC7kOeSfeGJD1AFYd0FplEdcvOa27MIQa+nQ85CvzHsqAdCG7JYUyL
gV37cmB0hmC0nixJkJoVTWGWhbIYuUU45WGAjCVqoFtzUyXaqBcSInM9KDvAo95l
76jriyBzcmD5j5+SjXz7/hdmPO3gnapasQhVCkuDEiGh04wm1/6f6GOjFg0Xh4Ss
4cT4k9LPNqOeqN5XlTtDEC3+fAMYtdGii3uFoxSZg8dv3QIybf8F58p7V6CJ+KTC
by6rFjTFJKFDbyCZvSzXKXzgWVihqfi2Y4ZXhKg+dXSapEBH3E4IDwOOQ/YlkmXt
VMCk7R+3gCIfT3OQhgWB9PfRs2ZGCiTOwSUvin39hvJTwgVkMfnovbllUID6lQZ9
2PeDYi5eUe7/ISdIISTs
=k99H
-----END PGP SIGNATURE-----

--=-IdEfso3CxfPLKxjBEzJ2--
