From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Mon, 06 Jun 2011 10:31:05 -0700
Message-ID: <1307381465.2698.5740.camel@jtkirshe-linux>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
	 <20110523151336.GF21309@gospo.rdu.redhat.com>
	 <BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
	 <20110524163323.GB28521@hmsreliant.think-freely.org>
	 <BANLkTinoRXmEAp0mbZdxSmMbntsE-QeRsQ@mail.gmail.com>
	 <20110525152023.GC11867@hmsreliant.think-freely.org>
	 <BANLkTin2HaYjHgGACkwvKwuY-Y_e3+r3JQ@mail.gmail.com>
	 <20110526135053.GB12617@hmsreliant.think-freely.org>
	 <BANLkTikrsr5sZ4aZ5aEmfBSvPE0mEL8g0g@mail.gmail.com>
	 <BANLkTin4VyK3boPqDQnd+Dkv6==cHww9PA@mail.gmail.com>
	 <1307379022.4994.4.camel@Joe-Laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-UmKg0251LjjoikTtd3AG"
Cc: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:7218 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753300Ab1FFRbH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2011 13:31:07 -0400
In-Reply-To: <1307379022.4994.4.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-UmKg0251LjjoikTtd3AG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-06-06 at 09:50 -0700, Joe Perches wrote:
> On Tue, 2011-06-07 at 00:34 +0800, Am=C3=A9rico Wang wrote:
> > I agree with this, IMHO this would help to organize the code better.
> > And currently only tuntap and bonding are still in net/ directory.
> > In any aspects, now we are mixing net/ and drivers/net/ currently,
> > which could be improved.
>=20
> There is a proposal to move some drivers/net content to
> drivers/net/sw/
>=20
> http://vger.kernel.org/netconf2010_slides/netconf-jtk.pdf
>=20
> I think that'd be fine too.
>=20
> I believe Jeff is going to submit patches soonish.
>=20
> http://comments.gmane.org/gmane.linux.network/197232
>=20
>=20

Correct, patches will be sent out here this week.

As far as moving tunap, bonding, etc into /drivers/net/sw that is the
eventual plan, but I have not done this work for this upcoming patchset.
I want to coordinate this work with Stephen Hemminger before I do any
moves.

--=-UmKg0251LjjoikTtd3AG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJN7Q7ZAAoJECTsCADr/EWUr4kH/RwZmFoD0ATokCzqsUxrVslk
I7A0AG+6z1rH7jSOqSE/msQAkuAujsoevz10e4+k1baB97Y0OteRa+ZHHSVbmKgL
1FzGo8WmpfvDey/pQjWI5KVB39WwN+/ihgTRrWQ4p0uEez/CebxBfwreF8dTbpAE
DEB1OfoEmjqncmmuAWlJBcws2hfoo8nDmDgBkSjw7O4J//rXKUxDGQ8wPJ7wOwnJ
hydeqkjcaEiYx7BNj6iWh1fI5myDmaXcjYq4+UHdXNKj3hju5raUEVVnE8chUIMd
h09eIuJaPV53DmFScSYeEompDRK+FZFyfn44sPOj/aOxHpqgyK6QoDdQoje+szg=
=Cl3D
-----END PGP SIGNATURE-----

--=-UmKg0251LjjoikTtd3AG--

