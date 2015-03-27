From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v2 2/2] ixgbe: Add the appropriate ethtool ops
 to query RSS indirection table and key
Date: Thu, 26 Mar 2015 21:15:39 -0700
Message-ID: <1427429739.2497.43.camel@jtkirshe-mobl>
References: <1427409886-20261-1-git-send-email-vladz@cloudius-systems.com>
	 <1427409886-20261-3-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Y5hJm16kctbFxopitE0v"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36700 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751035AbbC0EQB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 00:16:01 -0400
In-Reply-To: <1427409886-20261-3-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Y5hJm16kctbFxopitE0v
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-27 at 00:44 +0200, Vlad Zolotarov wrote:
> Added get_rxfh_indir_size, get_rxfh_key_size and get_rxfh ethtool_ops
> callbacks
> implementations.
>=20
> This enables the ethtool's "-x" and "--show-rxfh[-indir]" options.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 42
> ++++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  2 +-
>  3 files changed, 44 insertions(+), 1 deletion(-)

I have added this to my queue.
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-Y5hJm16kctbFxopitE0v
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVFNlrAAoJEOVv75VaS+3OyCkP/3+95J0jMBpDDqTs7eBNBsqQ
0lpXY9TKd4fiD1tM3WRKhyqVa/AZmKCMhzKS9IDHrLn5BAcMWp/cJFjHmytlpz5V
ajth8/GBeFZIFFymaNZSldywluJ+nblyxuxOpYCX5LTITAHT1w7lJdMK5rBzDddm
yiked2qvnXMI6hSOHo2b8S0rvfpTbQUIcPbxiT3MDsovLFfCaVPqW/eEhffHuzc+
n3dHcUK9hnEq//UoWWRSXEbwlpjNwF+Wx8EFaRXUcPcfBipYwMRUJGZgqkrr3/vt
cgWa7mTw75lFn9Z/PzTGLwD0H8N3sTdX3rVt2C9RVobhfxyOK5vnKjRPOohGeq4A
QgkBYcly4JYiiYGsOtA4IORgido60OECbNskwiqBp7JHVpSeHZ3DODrgWwJd2Pa7
Ot7TSLax7uEtere2wLk55AYCpmIKvKpwtUkuYAzzS5SgZLe/zzdHElrEXLdZsIbu
8o4ywVudz3NMDe96uRbIuF5paM0G7rZT8pm1ilfsqffnQiT/JzfxFUtalE1PsDlo
4RY86JiIcFX1XOqUn41F4rNIkkGcClypOXXKfW39XEJlaFH1jmn7SvijDzvDt/Oh
n3dOC844RbMB3pdsfZZ073X52JuJnCZ040/R/6T7t29f6nGdT0KS02ye7Pg38MQC
zxXsai8HkxKxVXi6qs97
=18vK
-----END PGP SIGNATURE-----

--=-Y5hJm16kctbFxopitE0v--
