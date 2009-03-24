From: Scott James Remnant <scott@ubuntu.com>
Subject: Re: Network Device Naming mechanism and policy
Date: Tue, 24 Mar 2009 18:20:07 +0000
Message-ID: <1237918807.22009.47.camel@quest>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com>
	 <1237914139.22009.18.camel@quest>
	 <20090324175203.GB22700@auslistsprd01.us.dell.com>
	 <20090324181202.GE5925@nostromo.devel.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-7PNCfW4uU1knhl0bvuTK"
Cc: Matt Domsch <Matt_Domsch@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bill Nottingham <notting@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zelda.netsplit.com ([87.194.19.211]:42281 "EHLO
	zelda.netsplit.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755125AbZCXSUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 14:20:06 -0400
In-Reply-To: <20090324181202.GE5925@nostromo.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7PNCfW4uU1knhl0bvuTK
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-03-24 at 14:12 -0400, Bill Nottingham wrote:

> Matt Domsch (Matt_Domsch@dell.com) said:=20
> > > Now consider USB.  Would the device name change depending on which US=
B
> > > port you plugged it into?  Or is USB just a single slot, in which cas=
e
> > > what happens when you have two USB ethernet devices?
> > >=20
> > > The Apple USB Ethernet device in my iPhone is not the USB Wireless
> > > adapter I own, both have very different networking configurations.
> >=20
> > we would obviously need a solution.  eth_usb_{something} perhaps.
>=20
> Right, but having biosdevname chase each new bus that comes along
> sounds iffy. I'd prefer /dev/net/by-name symlinks, if at all
> possible. But that's a lot of code that I'm not prepared to write.
>=20
Not to mention that All The World Is Not x86

Scott
--=20
Scott James Remnant
scott@ubuntu.com

--=-7PNCfW4uU1knhl0bvuTK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAknJJFcACgkQSnQiFMl4yK4t0QCfXmptkOlElpU/lt7RVDXiBBRP
64gAnivtt8kf+GBOkfh3ddJ0Ql9kpuBH
=k0vJ
-----END PGP SIGNATURE-----

--=-7PNCfW4uU1knhl0bvuTK--

