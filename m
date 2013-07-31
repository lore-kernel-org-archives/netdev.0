From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] igb: Add macro for size of RETA indirection table
Date: Wed, 31 Jul 2013 02:14:54 -0700
Message-ID: <1375262094.2877.31.camel@jtkirshe-mobl>
References: <1375260212-19351-1-git-send-email-laura.vasilescu@rosedu.org>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2xo3hTqzqD9M/o0vt7XK"
Cc: netdev@vger.kernel.org, carolyn.wyborny@intel.com,
	anjali.singhai@intel.com, alexander.h.duyck@intel.com
To: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2339 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755476Ab3GaJO5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 05:14:57 -0400
In-Reply-To: <1375260212-19351-1-git-send-email-laura.vasilescu@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2xo3hTqzqD9M/o0vt7XK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-07-31 at 11:43 +0300, Laura Mihaela Vasilescu wrote:
> Signed-off-by: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
> ---
>  drivers/net/ethernet/intel/igb/igb.h      |    2 ++
>  drivers/net/ethernet/intel/igb/igb_main.c |    2 +-
>  2 files changed, 3 insertions(+), 1 deletion(-)=20

Not sure if I mentioned it in your first submission, if I did not then
my bad. The title of your patch is descriptive of the changes, but it is
always nice to have a detailed patch description.  I noticed your second
patch is similar to the first, in that it does not have a detailed patch
description.

Information that would be good to include in the patch description is:
- why the change or reason for the change
- advantages/disadvantages to the change

Laura please re-submit your two patches with a detailed/meaningful patch
description to at least the second patch (but both would be great).

Think of it this way, if someone were to look at your changes 10 years
from now and did not understand why the change, your patch description
would explain all.

Cheers,
Jeff


--=-2xo3hTqzqD9M/o0vt7XK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJR+NWOAAoJEOVv75VaS+3OIzUP/iALFDtjbuXXtA4wdQY8LBFp
z1XIBDPHxG6qbUaamA6tfjvHmaTB/lgl/yes1xVGmArr78HNUPn92BsKzlkaUK3c
oMexVDrcSc9xIagBAY7DhjhCbCOwSuqc6HXcQcmBy7+bJ+JFlRMcaXypEuoEPXHl
ZLbq8c0uKMcvM3NEDV2x179RHUWKLK/NisFBYJ7tEjToHv9xNC70bu58M94JEgpt
fHu1wxj+x0iznSaTwYz8WJnpYFC3nQX/NA5/SklRy1pAphmDAYAANaTMJY5xHKMT
SQm/PSa6X+zi673+hOBuF/08iJH9NApmMxXs8br48q+FoB/k8G0Ci9DuJw+RQhh/
CwgkzenvlNzgGU+E92SwDos+HJGx0h58gFGmTuGEgv23H54dUudsLxxFEEnWQ9BM
kiXveP4lybT4ngy0a45XFizN/MsrswgwId0JI1xWEYcVAzhsgzTZuD9yQc5qkT2B
Cew37lr8m9jNmlS17ay02rCIrAyrhFDj5gXlMZUIQp0K5FNPfnFyk7fLfb6oCq+K
1qMWboE5QJa/7R4YUUMckGhVLzVgcAsDE4oFlQ4VUIfIWUU2SFnQG4iSoJlfaHKh
l8mSTFdnVNAr6ejp579ntTwAv4DcevU61A51BCO8C4zze+tUnfId1eukRC3WsY3Y
jtMRImvY/C46uhEBpmyk
=OQxV
-----END PGP SIGNATURE-----

--=-2xo3hTqzqD9M/o0vt7XK--
