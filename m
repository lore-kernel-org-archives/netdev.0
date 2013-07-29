From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Mon, 29 Jul 2013 01:34:45 -0700
Message-ID: <1375086885.32309.39.camel@jtkirshe-mobl>
References: <1375053098.32309.28.camel@jtkirshe-mobl>
	 <20130728.172022.2147023715179571146.davem@davemloft.net>
	 <1375063735.32309.32.camel@jtkirshe-mobl>
	 <20130729.003405.2285412976756507988.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-QHTecDEhGmEB1eLm9AIg"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39150 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751330Ab3G2Iet (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jul 2013 04:34:49 -0400
In-Reply-To: <20130729.003405.2285412976756507988.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-QHTecDEhGmEB1eLm9AIg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-07-29 at 00:34 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sun, 28 Jul 2013 19:08:55 -0700
>=20
> > When will your kernel.org net-next be updated?  I ask because I have a
> > series for ixgbe I am putting together and wanted to make sure it is
> > against the latest net-next.
>=20
> Are you asking when I will next merge 'net' into 'net-next'?  If so,
> I'll likely do it some time tomorrow.

I am not worried about that.  I just cloned your net-next tree and did
not see your pull of my net-next tree which had the e100 and e1000e
patches.  I am working on creating another series against net-next and
the tip on kernel.org is:

commit 9d4a0314642918cbda9ed4012df51e8df608fce6
Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date:   Fri Jul 26 17:05:16 2013 +0200

    ipv4, ipv6: send igmpv3/mld packets with TC_PRIO_CONTROL

which is several days old.  So I was not sure if I just make my series
against my net-next tip.

--=-QHTecDEhGmEB1eLm9AIg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJR9iklAAoJEOVv75VaS+3Os4AP/RZmIJmspicESafEXNwBwct9
PYiVziA5NimUdwlgB1+DJCgFEWsgywNp7Psudy9Dc7ZC5k5Mvp0OTdnOTZH01FAY
APBEnk0aktXVWQjqSn6Dz5zlNJ1ZVldelIEma6cYg8QyA+9Jyc0j5awCrE4Kp4U3
p7oCVFWIPLXPVp7dOuS/JQPJDAZqN4UwN3Hzt8p9+zLRcoNRFI0Vm+ipDUhoqowx
YBqzKPyYWhRmQf/aZmT9eVutELw6ZOpcUVuVqpCvAYvUFhCZBYs2yvotLsN1cHHX
AvAygHM9rN5H9tYqLFHCWTfh7PwbAJMfLWVljPNYuP1m/v+PrC3fMG7RXteSJgac
l5hmFmILglYj0ke0kWAzxbg0wFsbpBcpqKVx1Z8FOgQqjVgqSewY4zMMA5q1Enwl
RmiKdmHSjdhGm7cbpxfBF8x3NqDXSGwRLW6WlQCMuOJto+TSVgP2vUMa1Dc0gRfH
X/mvkdp4VAAaHWOQ+dpkjX3KhD2gXvvC30POZUyma2pE07bkDbPl0bdOMMlh1qzc
xZSmBe1806Lqy8MTQNhang67NylQXQ7BsFqibje7B8NAxLdYJMIk5dBJu0hvMXIk
nw4UF1QFyn+NBf/IRQvsuIl7WDFiAi9tmunULs0mdF9qbk6M7dxleBBD9OQMc4L6
GXqOwSPiqgVreaVTQtUV
=vd1z
-----END PGP SIGNATURE-----

--=-QHTecDEhGmEB1eLm9AIg--
