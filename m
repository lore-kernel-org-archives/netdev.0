From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6 00/12] Convert more drivers to ethtool
 set_phys_id
Date: Mon, 04 Apr 2011 13:35:01 -0700
Message-ID: <1301949301.3842.3.camel@jtkirshe-MOBL1>
References: <20110404184340.604594357@linuxplumber.net>
	 <BANLkTimfFPEhr4GozxBZB5Pc-LGXWfGTPQ@mail.gmail.com>
	 <20110404.130624.63023544.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-wZQI1MGz1e8pENEBd7+S"
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39007 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752970Ab1DDUfL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 16:35:11 -0400
In-Reply-To: <20110404.130624.63023544.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wZQI1MGz1e8pENEBd7+S
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-04-04 at 13:06 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Mon, 4 Apr 2011 12:53:14 -0700
>=20
> > On Mon, Apr 4, 2011 at 11:43, Stephen Hemminger <shemminger@vyatta.com>=
 wrote:
> >> Did a bunch of the easy drivers to convert.
> >>
> >>
> >=20
> > I have added patches 3-9 (Intel driver conversions) to my queue of
> > patches.  Thanks Stephen.
>=20
> Careful, Ben's commit to add the interface still isn't in the tree.
>=20
> He needs to respin his patch set based upon feedback that came in
> the other day.

Yeah, I caught that.  I will be adding the dependent patches to my
internal tree for validation purposes only.

--=-wZQI1MGz1e8pENEBd7+S
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNmit1AAoJECTsCADr/EWUt/oH/1AjDwfLgqfTNxl3GIMHw4q3
nqe4nq7hL1wmArA0PVx/CLt8qfdF5yXUCbY+JG0j4uK+W9ORt1dAwiRXeHaeErfV
0+9Vxx6jy7l9mJbREf/3/1+0VioG2LBibn2v8lUR3iUZv7sW++jMKWAMwmmF+3PY
yo8TmKnjVA317rjRaXeUXxMzgqDNyrIJNkJdMniMRKh3bqUJOh4hoRpkIAIGq5gy
NZzcRR2v4WM089CWiRBYsRBI3oeCcadJ1r3sVXADb0tf40fqOTH0TSyVrCimoCLx
PKQ2bU3h3ztqGOhSTWKIQqlZAMazvQ2jPhgfDxsdLr+LDJATMJ69XMg7GYhBy4s=
=oduk
-----END PGP SIGNATURE-----

--=-wZQI1MGz1e8pENEBd7+S--

