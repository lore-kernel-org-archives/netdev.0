From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Mon, 09 Apr 2007 18:37:08 +0200
Message-ID: <1176136628.8459.34.camel@johannes.berg>
References: <m1abxl5j4s.fsf@ebiederm.dsl.xmission.com>
	 <20070406133420.2f098bc6@localhost>
	 <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Vg10kErGQGG/o8WKLqGn"
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Ben Greear <greearb@candelatech.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Dmitry Mishin <dim@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35683 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966233AbXDIQhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 12:37:53 -0400
In-Reply-To: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Vg10kErGQGG/o8WKLqGn
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-04-06 at 20:51 -0600, Eric W. Biederman wrote:

> The only sysfs attributes that were always available that I could find
> were module parameters.  A little odd because we can specify them on
> the kernel command line, or when loading the module in addition to
> being available at run time. =20
>=20
> It gives me a general interface that is usable so long as the module
> is loaded, and does not depend on the availability of any specific
> network device.  I will happily use any other interface that gives
> me the same level of functionality for the roughly the same level
> of effort.

Just for consideration, in wireless we currently create virtual network
devices by having a "add_iface" and "remove_iface" sysfs files below the
ieee80211 class.

johannes

--=-Vg10kErGQGG/o8WKLqGn
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGGmu0/ETPhpq3jKURArALAJ95X4RKH0SobCjtoxPaHxqU42YlBwCeI7A7
HM6NlSQPQJHwBr0CjO4Fwe8=
=aA71
-----END PGP SIGNATURE-----

--=-Vg10kErGQGG/o8WKLqGn--

