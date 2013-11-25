From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 4/5] igb: Start temperature sensor attribute index with 1
Date: Mon, 25 Nov 2013 15:17:47 -0800
Message-ID: <1385421467.2270.16.camel@jtkirshe-mobl>
References: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
	 <1385186881-7931-5-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-f2BmIOG1F4VKcn8DMp9t"
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	e1000-devel@lists.sourceforge.net, lm-sensors@lm-sensors.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14202 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751975Ab3KYXRs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Nov 2013 18:17:48 -0500
In-Reply-To: <1385186881-7931-5-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-f2BmIOG1F4VKcn8DMp9t
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-11-22 at 22:08 -0800, Guenter Roeck wrote:
> Per hwmon ABI, temperature sensor attribute index starts with 1, not
> 0.
>=20
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
>  drivers/net/ethernet/intel/igb/igb_hwmon.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)

I have also added this to my queue, thank you.

--=-f2BmIOG1F4VKcn8DMp9t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSk9qbAAoJEOVv75VaS+3OSs4QAIDhuBtyJ7eP/AXMdgrp+xyG
6nzNRSP4JyfBl1fq5zT46XoBYvN6k4xDzC/Hdb5LymE4LP7egJsrKJ7ABZ2kb5lN
hUuRaedybwyX65xnf9tw7fQyfPrJloHo1McwL6Ye4J5tcJHSVnqD5I+vHHSMFc+L
JkJRYhV2+tUIJ3QHFpMAA7MH8ruiYT56TsFWhS7A5uXLt8t2FYbYpmJpvkuIMrX/
o9h/alBHj66oc/lVVFckyZiOVUGFmUbI17Ic0vokc82c9JzBcnJzGk8aHiwutACv
8fE9NEsOpwcj20vzz6MoszxWaYfZ8NTDuFIloW0Y+r13pAvQ+JP8GzieyDrtfAuO
/p/UZQbYRFeFifag1kdlm/J8CFVPEKmMGth+6jQcH/kcbUaviXtA7mbMTEnBMfeU
1A54j2ofdy2NqLlkXd2xKCvvPOY/jmircCdh+0u4Mx7uekMZOoJlmN0DA+BWiora
CgjbKTl9jvPyriNaq3GvcD6rqZnYkRC6/I2InrYLrLzFxzQ21BB+UgCyKAvFMR9T
LrkO/5tWYyGynoSjRk9dXtBG70LRhm/JBzy5Vb2chvNxeKMRQop/FoYz/NTi3n4U
5Q6vi1I/iBlsrogGXfHojw/DXN00TRJtHeAIs6om4D9Pvaw2PMMJkqlNOw/YDnwf
4GlS8wJW2f5eoi0YjcoO
=O4HA
-----END PGP SIGNATURE-----

--=-f2BmIOG1F4VKcn8DMp9t--
