From: Sebastian Reichel <sre@ring0.de>
Subject: Re: [RESEND] [PATCHv2 0/5] wl1251 device tree support
Date: Thu, 13 Mar 2014 19:01:52 +0100
Message-ID: <20140313180152.GA21701@earth.universe>
References: <20140125000929.GD25488@atomide.com>
 <1392419156-14394-1-git-send-email-sre@debian.org>
 <20140226194436.GA20992@earth.universe>
 <20140313170038.GA20372@earth.universe>
 <20140313172726.GC30579@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="IS0zKkzwUGydFO0o"
Cc: Tony Lindgren <tony@atomide.com>, Luciano Coelho <luca@coelho.fi>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140313172726.GC30579@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 13, 2014 at 01:27:27PM -0400, John W. Linville wrote:
> On Thu, Mar 13, 2014 at 06:00:39PM +0100, Sebastian Reichel wrote:
> > Hi,
> >=20
> > On Wed, Feb 26, 2014 at 08:44:36PM +0100, Sebastian Reichel wrote:
> > > On Sat, Feb 15, 2014 at 12:05:51AM +0100, Sebastian Reichel wrote:
> > > > The following patchset adds device tree support to the spi variant =
of the
> > > > wl1251 driver, which is used in the Nokia N900. Tony requested, tha=
t you
> > > > take the whole series even if that may introduce merge conflicts:
> > > >=20
> > > > > Sebastian, please resend the whole series to John and feel free t=
o add my
> > > > > acks.  It's best that John picks them all up, otherwise we'll hav=
e the same
> > > > > issue for v3.15. It seems that we should have just taken the merg=
e conflict
> > > > > rather than going back and forth with this.
> > >=20
> > > ping! Is there still anything wrong with this patchset?
> >=20
> > ping! This patchset is quite old now. Please pull it into
> > wireless-next, so that it can appear in 3.15.
> >=20
> > -- Sebastian
>=20
> These are already in wireless-next...

oops, sorry for the noise. I have checked the git repository and my
mailbox before sending another ping, but overlooked the commits.

Thanks for applying them.

-- Sebastian

--IS0zKkzwUGydFO0o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJTIfKPAAoJENju1/PIO/qabJ0P/RO7ZR94Hp2AJ7Hd3w5Y2NHI
TiIEHy+3sX4ghx5g/8WGbZwLaZlVLGNYl5MtkIl8seUVGvyQeh3OHZ6U1cykPoac
eBEjUYynnibyeXIYf5yibVp9GFFg7Ik2RYTJklgMDTptVAcK7vzyZA6mpB9GlZWx
f6Kyx/MPmDk62GLjYWC25s00fSonz77+K0gd1pQ07zRmZ8AmS+7pwR4Qt6Bx3Tl1
vuSCN0679KJP2iDBuNlNm6A2uE+joa30W+9KR+lTUR0DHd93hUjPBbEwp687MQJ4
uVoI6R1spA2EILKBaWgbfM4QYJxTPXFHbpSb6YcXBYg1ygwaAOa1RV6dTyGUDVFM
+fYtJPGoZGM2v9aden7oFsv/iklc9Op6GExEuIx7Mz/0HvpH/BT8+6xeDolZxTkI
SvNBeDDZoC2rXIQDJlQvGW4nTcu6MBXnFHIyg2kodP6trrOdYLoZbn8FdJ4LIkMz
0J9CWhSpzhksLxP5ztSKlJPYG1Ir9mxvqasMT8pT5F6pa1LP/lt1DQOLSiwoe4+B
A/1EY9fb8Hs+3h9uM5A6kp6jB3ShP0yczl3mOxD5dat9uQmqSJdQmVpgyMTX1J8o
+bfnAutjFRz7w8/bAIUSywOkkN1dkmrAwwLDtOTq1kGNKMfZLK/yerM2zQvDSoAG
e0GjYjNnu/pyqZUot6kd
=0wKX
-----END PGP SIGNATURE-----

--IS0zKkzwUGydFO0o--
