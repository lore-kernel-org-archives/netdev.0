From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [BUG] igb: panic at boot time with latest Linus tree
Date: Tue, 31 Jul 2012 01:51:33 -0700
Message-ID: <1343724693.2230.18.camel@jtkirshe-mobl>
References: <1343715255.21269.47.camel@edumazet-glaptop>
	 <1343715971.2230.4.camel@jtkirshe-mobl>
	 <1343724174.21269.168.camel@edumazet-glaptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-3GQF8tPzvGb3xs+p1fNS"
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:6795 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755849Ab2GaIvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2012 04:51:35 -0400
In-Reply-To: <1343724174.21269.168.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3GQF8tPzvGb3xs+p1fNS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-07-31 at 10:42 +0200, Eric Dumazet wrote:
> On Mon, 2012-07-30 at 23:26 -0700, Jeff Kirsher wrote:
> > On Tue, 2012-07-31 at 08:14 +0200, Eric Dumazet wrote:
> > > For information, I get this each time I boot on latest Linus tree :
> > >=20
> > > RTNL is left locked, so machine unusable.
> > >=20
> > > No problem with David net tree, so thats a bit strange...
> > >=20
> > > Not sure I'll have time to investigate today
> > > (And tomorrow I am off for the day)
> > >=20
> > >=20
> > >=20
> >=20
> > I have an igb patch current in test to fix a panic in igb.  Here is the
> > patch:
> >=20
>=20
>=20
>=20
> Ah sorry for the false alarm, it appears I had igb module in a out of dat=
e initrd file (coming from my net tree)

No problem, thanks for the feedback.  Whether or not it was false alarm,
the feedback is always a good thing which helps us improve.

Cheers,
Jeff

--=-3GQF8tPzvGb3xs+p1fNS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQF5yVAAoJEOVv75VaS+3ObYkP/37NQ58PFS73dLiqcKkwRBD9
0m7Wh0G7uSC8vOwuUCby0E4b080EjGHFKqk3T45qkQK2DaFj+R/GNqZVtyVC+i5p
DdqD7tJZ28XThALeCYS//4Pko4xsC6f4/rmle99+cMx0pv02sYtt5070J2jxKdMR
m0hcJKfvnk2uy/kjhjKooPVclobwsHTSiDiZhM6QphR7dR9fIMT+VU5QWPpN4pJv
MyC8IEJTuqhhMaLF9XLO+nqqSIZaeL6PRJ59s/wPCWYoSFZbv/xlNhfJIZzf32mp
y69GVTzcS/Oiy03A21wjf1OF8yfLg86uYs+ZlmiphblSutFst9O6+tMUboj1/HxF
dSvIISgtivj3ZpZ8MXCrD1S/3KzaOIDG8bBeBfSiz5sMlwtxx3akPI7a4TwahFto
Dbs3Vub45P4+lz3YnfBoWUjO+AOk4MM+/7/AGHR4USix547Wc4RP+wS7ySKw7Yyr
7AC6ulaqGcwMuE4FXILVosFDoU1uWjpUnn4zd0lg8iqFZ4DdBQTpdrFBbtRA4o6Y
RIOON4YARlADQ1CmDvj8/b0bfZZvtJ3+PP1jEJ6uHUCATTKxl4PMFhguLN6zHF9t
5bdApBeJIIbQg9E8hv+Iv07z58Ukz24wJJ28hmuZzkvidS1dTh79vbjHwEq9+HkC
fMsMvcVWpVFQvqjz8E6U
=VbBN
-----END PGP SIGNATURE-----

--=-3GQF8tPzvGb3xs+p1fNS--
