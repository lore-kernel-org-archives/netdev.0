From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/2] igb: Expose RSS indirection table for ethtool
Date: Wed, 31 Jul 2013 02:15:22 -0700
Message-ID: <1375262122.2877.32.camel@jtkirshe-mobl>
References: <1375260212-19351-1-git-send-email-laura.vasilescu@rosedu.org>
	 <1375260212-19351-2-git-send-email-laura.vasilescu@rosedu.org>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-YTvNZUeoQ4avbYZwafjO"
Cc: netdev@vger.kernel.org, carolyn.wyborny@intel.com,
	anjali.singhai@intel.com, alexander.h.duyck@intel.com
To: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:32049 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753044Ab3GaJPY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 05:15:24 -0400
In-Reply-To: <1375260212-19351-2-git-send-email-laura.vasilescu@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YTvNZUeoQ4avbYZwafjO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-07-31 at 11:43 +0300, Laura Mihaela Vasilescu wrote:
> Signed-off-by: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
> ---
>  drivers/net/ethernet/intel/igb/igb.h         |    3 +
>  drivers/net/ethernet/intel/igb/igb_ethtool.c |   87
> ++++++++++++++++++++++++++
>  drivers/net/ethernet/intel/igb/igb_main.c    |   28 +++------
>  3 files changed, 97 insertions(+), 21 deletions(-)=20

Not applying, see response to the first patch.

--=-YTvNZUeoQ4avbYZwafjO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJR+NWqAAoJEOVv75VaS+3OE84QAJ8NN9wZwuwbW7g49znPvSTd
aSMNqH+1d7LtKGUqrA9TIhV+6CAHoE0FvepOIeHQWr0sZ2URXHLalN6KJSzofBXu
yEKDSFxE/huSUcuszO+XloaMbswc5hjw9QMEkFoX1uemUGgbheyM6UZgZ/LtdjTr
rZZqDd1jM+DUruUwg2J2wjSmebBqRhz/U935slbGqS/im5Vd7Y8EdLwbnfw/9oPI
0hoayos/n5fIsBIzcRrB2bQ9L+OKqZ23F5Tn23xd/NHAowp58Z8PlYDRxt9cI7wm
FL8KUOJDGKq1j8EWRKWhcBdzUWZJ1PJ8fHWzAZTNhMpIXcVRLjAZeK1lAL/EV5M1
C+ABgsjv38y6bCKLygXPn/+NSlcJr006THWrhhN2kmePKWQag2BvMVFUbyKTYg3X
ddvbmtm1k9swJVwynUIlcVASTmVgJyUkKj7JRIBRhuzZ7w0Nv5BUEoTUQU8TNjqa
P5AhtyEl9hRpntW8Ux3096Li5Z3oEWlR2dDMjNFL8e++2nR8OGkER+VfuajyzWSW
UzWgjlaqg4qhT6tHj1TrCHp8CaVWZyjgA8VA4H/yJtf4X2gNwvnokG+OcOzxRHH4
Bd0ke4YHQe/PWVNpm4uI/fASuZeS+7K8BP6zSnqk42QjHdAOLHZmsBKrOliTGsU9
u4OZkFxet6C8V46xmrtz
=TYDZ
-----END PGP SIGNATURE-----

--=-YTvNZUeoQ4avbYZwafjO--
