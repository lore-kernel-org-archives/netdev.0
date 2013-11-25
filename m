From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 5/5] ixgbe: Start temperature sensor attribute index
 with 1
Date: Mon, 25 Nov 2013 15:18:02 -0800
Message-ID: <1385421482.2270.17.camel@jtkirshe-mobl>
References: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
	 <1385186881-7931-6-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ALzdL2M9/rPWpGVe2sMt"
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
Received: from mga09.intel.com ([134.134.136.24]:10407 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752099Ab3KYXSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Nov 2013 18:18:33 -0500
In-Reply-To: <1385186881-7931-6-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ALzdL2M9/rPWpGVe2sMt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-11-22 at 22:08 -0800, Guenter Roeck wrote:
> Per hwmon ABI, temperature sensor attribute index starts with 1, not
> 0.
>=20
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)

I have also added this to my queue, thank you.

--=-ALzdL2M9/rPWpGVe2sMt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSk9qqAAoJEOVv75VaS+3OEDEP/AiqJhVQrta+qhYBehvb8PIl
sFAZKfG6vLwupii6gkUEHqJeZDqV2BqvMzZ6/l6VQb0ThsrnriyFawrAHWbx1jWQ
wovqfl/dPOT7it/wLdWiiCgnMAQmtf+NzkU7cxPyvYtZL3PW68x7OGQIdnXrAqVh
uXbRG19w7StesPVlqJBoB3ynVxPXIDx9c3L7yxuLyrVBibMvB50+AZD7tVupBUVq
V25UUy30W1Ed42NX/a+crmsm0By0LrL8WIO8v6T+XM2MgWbuXp/xrF/sw4mecmoi
tLrhhEdSwsIoKmDrQlnX9dMNLe8AFjZncS3zMMDMC4M//NnjCbDB0nxt3JS59LDP
p/Axb32kLBceJwWPUA2YWCadQTrcoRVm9ge1v5kKgHNnCXlTVmVouKmdzdULEhqS
bTtkOC56+EHtj9rD6lNn6+Q/w9ejtVeWXsx5mFF36X1xEF5ZkwutFQwPUX6PwiAi
bPcZFJlKNdG6ae56FyjWbSYOD2adBFG4xtDEGmnkwF0Djio9dKSJMSh9zhr9v605
t/UTXtiIiiGNHWgOvqsjS9qJMj1jKKyjM+cg5cuTLs/c2XurQRhTD8XgLxwXtEHx
4qTLqNH098kV51un1uhsXP5L1MORSp11VqtaKtuNYo0P/pNWPvRaGtxw/1v4SZoO
Vy8bZeDuqHBPkvp4BasV
=eJ6E
-----END PGP SIGNATURE-----

--=-ALzdL2M9/rPWpGVe2sMt--
