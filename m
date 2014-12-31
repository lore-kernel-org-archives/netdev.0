From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v1 4/5] ixgbevf: Add RSS Key query code
Date: Wed, 31 Dec 2014 08:28:27 -0800
Message-ID: <1420043307.31582.53.camel@jtkirshe-mobl>
References: <1420019519-18139-1-git-send-email-vladz@cloudius-systems.com>
	 <1420019519-18139-5-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-BRVhUNZX90Zh6HJ3fTRZ"
Cc: netdev@vger.kernel.org, gleb@cloudius-systems.com,
	avi@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:53098 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750726AbaLaQ23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2014 11:28:29 -0500
In-Reply-To: <1420019519-18139-5-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BRVhUNZX90Zh6HJ3fTRZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-12-31 at 11:51 +0200, Vlad Zolotarov wrote:
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v1 (compared to RFC):
>    - Use "if-else" statement instead of a "switch-case" for a single
> option case
>      (in ixgbevf_get_rss_key()).
>=20
> ---
>  drivers/net/ethernet/intel/ixgbevf/mbx.h |  2 ++
>  drivers/net/ethernet/intel/ixgbevf/vf.c  | 44
> ++++++++++++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/vf.h  |  1 +
>  3 files changed, 47 insertions(+)

Just caught this now, sorry but your patch description is sparse (i.e.
non-existent).  I know that the title of the patch pretty much tells
what you are doing, but it would be nice to have a bit more detail as to
why (like your first patch).

Same goes for patch 5 of the series as well.

--=-BRVhUNZX90Zh6HJ3fTRZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUpCQsAAoJEOVv75VaS+3OGTQP/jN270JELD0dxp8LK1N9c63e
v9ijEWJq6PBEkj3wXn3gEWmt/aKZHCsjEZorzh/ba55dxL0P3ocgDx5YvA90lMDc
Hsfd5YB7qOytw7YcmRmKru9OFhR1AwiVVlI8rUWJbl48AqVYjFdDl3lZmty8nOJU
TRTKorNmQBWFNSQFhbiYZsgirxitcmk4otwDFJshymim/YmnLMdti5JGzO2LJtKV
2gwi+8WjHU6jp2D0pEt6bL0N6pke/KjAVKK1EKo7SdMxqL33O+VMoPNZVaotPctI
zrVt6b7c6XXHyKx8QgNkpe9ufwRHgg/uWdSBMrNYIzVqOfDRKXgw4UzD8KDDPiC8
AQFjC1y2/6TFZJ3/RM3kds9qiptR9RfCJQcH9IPv4bktop2oV24v6CpPBIMJYJpa
NZWTF1mglvPkGoTMMTkV+/XIRub6PiQE7EMh/DLSLt+6LQI6RzigAI8hr9ZtVHia
x0480Q8BHQJJnhDG7XoaGCJstNyKStWpHNC66k8Z2MtztBM+FQh4vtZZOSAQiZ01
gxU0FRiq6cw9EALuOZG3mKVdb/4heE4Am5iNcRxjSMzhvPru4QjnJfSbd1ge0brU
Fam7Re8vA87en1/+6d/UWbo9VkEEAEcINybYEjxz7FJcaXZ9XSVA4X0eAsADkvZ2
PXuNIKq6b3S5m6CwO4Cj
=kArP
-----END PGP SIGNATURE-----

--=-BRVhUNZX90Zh6HJ3fTRZ--
