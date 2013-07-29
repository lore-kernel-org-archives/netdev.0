From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Mon, 29 Jul 2013 02:17:47 -0700
Message-ID: <1375089467.32309.40.camel@jtkirshe-mobl>
References: <1375063735.32309.32.camel@jtkirshe-mobl>
	 <20130729.003405.2285412976756507988.davem@davemloft.net>
	 <1375086885.32309.39.camel@jtkirshe-mobl>
	 <20130729.014643.2227589840281609643.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-XrORK+j5ynit501FFl3+"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36711 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751344Ab3G2JRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jul 2013 05:17:55 -0400
In-Reply-To: <20130729.014643.2227589840281609643.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XrORK+j5ynit501FFl3+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-07-29 at 01:46 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Mon, 29 Jul 2013 01:34:45 -0700
>=20
> > On Mon, 2013-07-29 at 00:34 -0700, David Miller wrote:
> >> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >> Date: Sun, 28 Jul 2013 19:08:55 -0700
> >>=20
> >> > When will your kernel.org net-next be updated?  I ask because I have=
 a
> >> > series for ixgbe I am putting together and wanted to make sure it is
> >> > against the latest net-next.
> >>=20
> >> Are you asking when I will next merge 'net' into 'net-next'?  If so,
> >> I'll likely do it some time tomorrow.
> >=20
> > I am not worried about that.  I just cloned your net-next tree and did
> > not see your pull of my net-next tree which had the e100 and e1000e
> > patches.  I am working on creating another series against net-next and
> > the tip on kernel.org is:
> >=20
> > commit 9d4a0314642918cbda9ed4012df51e8df608fce6
> > Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Date:   Fri Jul 26 17:05:16 2013 +0200
> >=20
> >     ipv4, ipv6: send igmpv3/mld packets with TC_PRIO_CONTROL
> >=20
> > which is several days old.  So I was not sure if I just make my series
> > against my net-next tip.
>=20
> Weird, it should have all of your changes.
>=20
> Tip is currently:
>=20
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=
=3Dfe6f700d6cbb7e8a61711e325f53d9c9e0a42a4c
>=20
> net/mlx4_core: Respond to operation request by firmware

All looks fine now, thanks!

--=-XrORK+j5ynit501FFl3+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJR9jM7AAoJEOVv75VaS+3O47IP/0J1LBLWrtA0deXm0x7WGv4v
PlGjU5/On8OTaC0dYzQwmb2RkMFU4OElB8B+CFwhHw17J1Sahd3OqOZJYvzqD9s2
1s2GE3HekAtPvo334p3694Ue43PIO3VigqGH2SzOGyI9t0nVzwVoL2o8dPR47tSa
mU8DXjAvljUOxBgfeGps6ewPjsEWsxGj4/4sjeZfFQreLz/QTnuGB7tYLspUn0UG
dMxO73iABfw2f0JT8ai5Df32i27a9guvBsw/6xFGV91wdoTWTnmbObf8fe6HkSdr
5jYdS8OF5Bj4ndqRdkCFq38AvbnmPZLErNHbmJCLtHCaUVDNjXoM9/QTnnO+1ex/
JdzPm5m1g2MbNDWG3z92Op0yXbMMVptIydogq4FeQ0jQd5CztBv+aVSaNoBdN/eT
ChUkv4qzjuQUL1rytxpJa8ZJNv6eAVTjv+r+lHFh8YMK4nX6AzqVONct9c+c0knB
cIVht+9fEOuZCsqgRE00SUFoC/iMk4h4ssF8N+Dnp344f+vlELaffJ8fITafa53I
GTuPhx1enozpcWvzDm1L5iDrJ0DNbAUhke6LVPGltmyk3AGgO1q7/qaOyTYTOjot
er7eR5A+4Cyv4A3eS50lRluFtdIeMwjkprxVg3hbel9CQJtgpdOFJpcd4r16GIi7
MB1FD/MudmmUnCv2KG0L
=lnZ3
-----END PGP SIGNATURE-----

--=-XrORK+j5ynit501FFl3+--
