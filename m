From: Sebastian Reichel <sre@ring0.de>
Subject: Re: [RESEND] [PATCHv2 0/5] wl1251 device tree support
Date: Thu, 13 Mar 2014 18:00:39 +0100
Message-ID: <20140313170038.GA20372@earth.universe>
References: <20140125000929.GD25488@atomide.com>
 <1392419156-14394-1-git-send-email-sre@debian.org>
 <20140226194436.GA20992@earth.universe>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="82I3+IH0IqGh5yIs"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>,
	Tony Lindgren <tony@atomide.com>,
	Luciano Coelho <luca@coelho.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140226194436.GA20992@earth.universe>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Feb 26, 2014 at 08:44:36PM +0100, Sebastian Reichel wrote:
> On Sat, Feb 15, 2014 at 12:05:51AM +0100, Sebastian Reichel wrote:
> > The following patchset adds device tree support to the spi variant of t=
he
> > wl1251 driver, which is used in the Nokia N900. Tony requested, that you
> > take the whole series even if that may introduce merge conflicts:
> >=20
> > > Sebastian, please resend the whole series to John and feel free to ad=
d my
> > > acks.  It's best that John picks them all up, otherwise we'll have th=
e same
> > > issue for v3.15. It seems that we should have just taken the merge co=
nflict
> > > rather than going back and forth with this.
>=20
> ping! Is there still anything wrong with this patchset?

ping! This patchset is quite old now. Please pull it into
wireless-next, so that it can appear in 3.15.

-- Sebastian

--82I3+IH0IqGh5yIs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJTIeQ2AAoJENju1/PIO/qa/uQP+QGEUssFuzxeHdgpihzHszVR
Fr65MaNUs3C5fnQWum6mnaf1uWKyC41Ex/KmbIOGrIdeMjx8vDq3X7jc4HC+54z9
RMEUL0uOVbtp1H8IWD1pXBvd6ePpziqpII8SV1hl0hz5xKsO0P0TPo+sCipcKGrU
+ib0NqSN0hSX0X1u5DP2k/tluuzsSUvjffUDQbVD75BCVvi5WmbBqbjHaX9wq9sK
uS0l4NoVsJUIJ2f7q7/Kmrv0uS0YmzzUIV1S0Ot2fqB7Hi+IJieKfPxYA4kM/1Rm
8DoPc4L8B9e2cuQnFzZa3jHcYFoJa/Px7xOtyHSGWLCChsmH4PTsmrylIPtJJJTX
Csvgr28L9AJ11BdiKdlfChZsDOYilxnnnlyezjSAMf7gg4ZczwGzORwiB6YcDj2n
Z+BAxfYuygsUVJNc3xUeRsSrTPg5WbQgOyQx+uD5FIwo+f98m1gDqFe/ibuSTzdR
BwfRwd9DOn02q7bf+4BnsM3fxt7iqY2SL5UgHCx4UJxw1eFtrGBqnFi6o8hf8mSm
nnON3vPtPdZ8TOYa+ajRjsvrS+i0mkWHbYIAOJ3A5hBn/wPEfJXzC4CZLx+/xS4A
gTc5fEG5Sw8sKVTtR9hZxrc+HDB9pSvoecZjBOm3DAT2AJVOeoQmMxE36qMPxoVv
n9PBoIP33ILd33WdO10y
=M0vO
-----END PGP SIGNATURE-----

--82I3+IH0IqGh5yIs--
