From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] net: intel: remove dead links
Date: Wed, 06 Apr 2016 15:08:56 -0700
Message-ID: <1459980536.2978.18.camel@intel.com>
References: <3c9f8ea384ba033f83ec360eef17732ff0a5a8dd.1459866280.git.jbenc@redhat.com>
	 <20160406.165451.42694079252458681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-dkrYtW+TlafYdsZemh1n"
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	intel-wired-lan@lists.osuosl.org
To: David Miller <davem@davemloft.net>, jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:13065 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753411AbcDFWI6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 18:08:58 -0400
In-Reply-To: <20160406.165451.42694079252458681.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dkrYtW+TlafYdsZemh1n
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-04-06 at 16:54 -0400, David Miller wrote:
> From: Jiri Benc <jbenc@redhat.com>
> Date: Tue,=C2=A0=C2=A05 Apr 2016 16:25:07 +0200
>=20
> >=20
> > The Kconfig for Intel NICs references two different URLs for the
> > "Adapter
> > & Driver ID Guide". Neither of those two links works. The current
> > URL seems
> > to be
> > http://www.intel.com/content/www/us/en/support/network-and-i-o/ethe
> > rnet-products/000005584.html
> > but given it's apparently constantly changing, there's no point in
> > having it
> > in the help text.
> >=20
> > Just keep a generic pointer to http://support.intel.com. Hopefully,
> > this one
> > will have a longer live. It still works, at least.
> >=20
> > Futhermore, remove a link to "the latest Intel PRO/100 network
> > driver for
> > Linux", this has no place in the mainline kernel and the latest
> > Linux driver
> > it offers is from 2006, anyway.
> >=20
> > Signed-off-by: Jiri Benc <jbenc@redhat.com>
> I expect Jeff to pull this into his tree, thanks.

Yep, got it queued up.
--=-dkrYtW+TlafYdsZemh1n
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXBYj4AAoJEOVv75VaS+3OQrwP/1xdcYmpQbw+FJ9lPNG+HVgT
ll0HFkOf7wi7Ay/THmhdFJcUnh0mtuBmF6IUQmnbaWaXeY5hvgc4fk3EDHnGWdgo
/sCrw+qgLUaR8WDssiGJlVQNiCDcVwjxbMF2WQ45DjATHKvEWSQZ2/kjoLkBtbG2
IEGD+Ws+mI4uC4amsnTR0/Z7IAnGDI1gJD9H+W83gVCTRkgo+wXxAhUUj+dQwHoZ
8dr8zrOButXlSzFNBND6i23bHzu0aymGnDDN59yBRS19xHjS2ThtRiPdVRet/YVM
/Hc7Q+kqo2AV7YNFSd6K8+CFBcXal1DwqJcWyLwnnNNT7P1Ltj1qKG6/Z0m/6MAV
AcRUexK5SJPbeyqmcN9eiKZ3TUI+GV2JfEy4Ok8h5SFrb69+WyH0rf46RsQ6C8IB
kwqesPmMY01NDojLSZ+1feT0fdJYBje4ZgdHLxq0GWFkJz96qAqfvyIjKewWq1xm
1Jzce4EITt/Zfxq7ITaeZF/rYuTFaKhoopukw7+8c62/6V8jNzy35EA/Kf3nSxgJ
oLtUqVeZczFMYBz7UVOnqx9+yGPOvKeM9TajxNEfHFoBK91dvtzkjCqg24ntTe17
jfprhmEjxc64v4qiqQAdyUfHgxXIXUq43UEs1h4n7XSGQ5+/CfwHydY0/PjyTRkm
DvcsNljzDaiG3jtfNkm6
=LP5+
-----END PGP SIGNATURE-----

--=-dkrYtW+TlafYdsZemh1n--
