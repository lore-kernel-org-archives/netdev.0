From: Felipe Balbi <balbi@ti.com>
Subject: Re: SYSFS "errors"
Date: Tue, 19 Feb 2013 12:12:09 +0200
Message-ID: <20130219101209.GK23197@arwen.pp.htv.fi>
References: <20130218153316.GA2663@arwen.pp.htv.fi>
 <20130218172700.GH2663@arwen.pp.htv.fi>
 <20130218174916.GA2070@kroah.com>
 <2721602.qxhJKWaVil@ws-stein>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ee6FjwWxuMujAVRe"
Cc: Greg KH <gregkh@linuxfoundation.org>, Felipe Balbi <balbi@ti.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Alexander Stein <alexander.stein@systec-electronic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2721602.qxhJKWaVil@ws-stein>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--ee6FjwWxuMujAVRe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

+netdev

On Tue, Feb 19, 2013 at 08:41:47AM +0100, Alexander Stein wrote:
> On Monday 18 February 2013 09:49:16, Greg KH wrote:
> > > Invalid argument - /sys/devices/virtual/net/lo/speed
> > > Invalid argument - /sys/devices/virtual/net/lo/duplex
>=20
> This is even true for ethernet devices which do not have a link currently=
 or non-ethernet devices (e.g. CAN).
> > LANG=3DC cat /sys/class/net/enp1s8/speed
> > cat: /sys/class/net/enp1s8/speed: Invalid argument
> > ethtool enp1s8 | grep -A1 Speed
> >         Speed: Unknown!
> >         Duplex: Unknown! (255)
> > LANG=3DC cat /sys/class/net/can0/speed
> > cat: /sys/class/net/can0/speed: Invalid argument
>=20
> Regards,
> Alexander
>=20

--=20
balbi

--ee6FjwWxuMujAVRe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRI0/5AAoJEIaOsuA1yqREGeIP/2ZAuPIyUkxI8eoU7E7Xw0vn
8Tq/Jz2uJjhULrkpPm35EtyY2pzSpED+yqaoOrgrXmXusbS7OYL5GDZjlP+cFDWW
hXt2l9I/MuKkB7hH3d0dq1fkaWUhg0aNVE4dHFCkgIU8nU6j25mJh3zyVU8a4n8Z
wyyYpiKFRZmdsoWKExYLDRudbKUARQXlIWe2DffmwwFeRf9zcncvkOryE7meh3YW
OzQ1JK6HGmHTyvA7WPNJkyvLC1npggmZa9vockGOlE1nLVjmh8fpGJssNdc58tZt
LRD2feX0wLhwPmHvk7B/Ydzkoi20FYJ+mFAb0JcsR9URRTJE4aVTTaefiB7A1eZ5
AGvazRnHhb5V91+yHBXvvZ0YdspZ3vIU4A21jwknG+D+i3YNYJfdl64rmODHCf4b
3fdW6gjqoPpuOYI3tato81S+Xc+sfYSaIJWuaaLXlV2eRh2CPQz1715LQdFWB5VD
PUVIZhMyuZlduE0cVpOnMwZpCRFKFtBze+RoUixQDVn/Wo88QBkJkyxYAp1ORPxC
soYUMZcEzr21EKJaG4mGw4XGoEqdMRV+A5JRyRVJpmrrz2H4BQ/aBhjR2ZWSX2cm
59B6349WQJFytG6J1xuZ1HtUbqal/Of1Zm97AfV8LnMZxRttzFVx5qp0vZvIqXYX
beIYFeahvKlzsvLJzo56
=dOuU
-----END PGP SIGNATURE-----

--ee6FjwWxuMujAVRe--
