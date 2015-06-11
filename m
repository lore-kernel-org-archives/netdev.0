From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net] net: igb: fix the start time for periodic output
 signals
Date: Thu, 11 Jun 2015 15:58:30 -0700
Message-ID: <1434063510.3530.10.camel@intel.com>
References: <1434027090-26866-1-git-send-email-richardcochran@gmail.com>
	 <20150611125310.GA26906@localhost.localdomain>
	 <20150611.155627.1888601708793677012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4ZeFYi6e+eHgy9S05L/O"
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	jacob.e.keller@intel.com, matthew.vick@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37311 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752219AbbFKW6c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 18:58:32 -0400
In-Reply-To: <20150611.155627.1888601708793677012.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4ZeFYi6e+eHgy9S05L/O
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-06-11 at 15:56 -0700, David Miller wrote:
> From: Richard Cochran <richardcochran@gmail.com>
> Date: Thu, 11 Jun 2015 14:53:10 +0200
>=20
> > On Thu, Jun 11, 2015 at 02:51:30PM +0200, Richard Cochran wrote:
> >> This patch fixes the issue by programming the registers correctly.
> >=20
> > Please also consider this for stable.
>=20
> Jeff, do you want me to integrate this directly?

Yes please.  I was just about to send email asking that.

--=-4ZeFYi6e+eHgy9S05L/O
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVehKWAAoJEOVv75VaS+3OsFEP/3atcThSmLQMQ5co3YmdVAVi
e/ov+O//vPmI9JhBuzkiNsgWp09/sIoYAPBskx0b4MP7T4+BLOy9+MEG9ix8yp3w
AYiccWLf9IdEB5ovE6VzY9/gZIRpgl2JpaFc4Q5nipWIMMxZF32m5GYTd9BBRiGN
YFL3jLHitlvwIKFqTfJO8COsWglEAFuDh6tiBAatKeiTxfVjhUTI8sDKj2//Ojm6
bJXJKNmXeHBFHi7D9mNlnKUsXZz6xjkXblPGTw+QvtLlHXaGSKCyOgh9/wwV0uJi
rNu0WhuPwUbH0XodFgoZfRpKaHA5/laWmdW78Rj0BZNJkB+7Zkp/EX/UoQX4vxcZ
JjtK3eg5ZIsTFKE8Zv6PTwKyTL4Qqvp5XI3CDLzcxQqaBRTOy6LXoYtQfPx6q2FV
F3/GPYdF2EzeVVdWOpvFwXVg8F/9EU18WMrGTkMy1BVeTsw5MuMRrmzBsD9MCIEs
8c9oogQ+p6NIHZZG8YlA7ecVQp8HOAzRl5inNQx9MAIVBlGTuWY0VwHG4PYoVA+6
S2k114jtyyzKtG8Wujh/6S9YyjQyX+ajNQ9UT/n71npzNIeyMY+4wtUOyOjcef6v
96+0NoVORp2cG38SL1sV2gr9oliYloNwPPyJdFdJxgc85GKZdKPRyIFe5vkax8Od
cDHCMtHK8B+DR3aTfz61
=rGSn
-----END PGP SIGNATURE-----

--=-4ZeFYi6e+eHgy9S05L/O--
