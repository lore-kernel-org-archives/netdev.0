From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 2/8] maintainers: update with official intel support
 link, new maintainer
Date: Tue, 23 Oct 2012 21:32:46 -0700
Message-ID: <1351053166.2252.39.camel@jtkirshe-mobl>
References: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1350987887-16161-3-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1350998701.7502.42.camel@joe-AO722>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-K4VSOEDDhJdK1OjD0Qb1"
Cc: Tushar Dave <tushar.n.dave@intel.com>, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49584 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755909Ab2JXEdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2012 00:33:00 -0400
In-Reply-To: <1350998701.7502.42.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-K4VSOEDDhJdK1OjD0Qb1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-10-23 at 06:25 -0700, Joe Perches wrote:
> On Tue, 2012-10-23 at 03:24 -0700, Jeff Kirsher wrote:
> > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >=20
> > Add an official link which is designed to guide the user to the appropr=
iate
> > support resource (be it community, OEM, Intel phone, Intel email, etc)
> >=20
> > Add the current e1000 maintainer to the list of Intel maintainers.
>=20
> Hi Jeff.
>=20
> I think it's unwise to have 10 named maintainers for all
> the intel ethernet drivers if there are specialists
> maintainers.
>=20
> Maybe it'd be better to break out these sub-maintainers
> into specific driver sections with you as the overall
> maintainer.
>=20
> Maybe add an internal exploder to get all the various
> maintainers on a list if everyone really looks at all
> patches to intel drivers.
>=20
> Something like:
>=20
> INTEL ETHERNET DRIVERS
> M:	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> M:	Intel Linux Support <linux.drivers@intel.com>
> T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net.git
> T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.gi=
t
> S:	Supported
> F:	drivers/net/ethernet/intel/
>=20
> INTEL ETHERNET E1000 DRIVER
> M:	Tushar Dave <tushar.n.dave@intel.com>
> S:	Supported
> F:	drivers/net/ethernet/intel/e1000/
> F:	Documentation/networking/e1000.txt
>=20
> etc...

I understand where your coming from and this has been been something
that I have been trying to find a "reasonable" solution, which is harder
to do than one would expect.

We do have developers like Bruce Allan who maintains e1000e and Carolyn
Wyborny who maintains igb and Don Skidmore (and others) who maintain
ixgbe.  The problem we did not want to fall into by pigeon holing
developers in maintaining a driver.  Developers like John, Jesse, Alex,
and Tushar work on all of our drivers.  Jesse tends to focus on
performance related matters, where as Tushar responds to customer issues
on any driver and does the root cause and fix for the issues.

So how do we go about giving this spider web of complex coverage to some
clear concise coverage in the MAINTAINERS?

For now, the solution was to list all the developers actively working on
the kernel drivers since anyone of them can work on pretty much anyone
of our drivers.

If you have some ideas which may help resolve the issues, I am open to
suggestions.

--=-K4VSOEDDhJdK1OjD0Qb1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQh29uAAoJEOVv75VaS+3ODNoP/jTITJilY+shqnJjV5vL+swE
myP51e8rp8fzBr5imP4OJf7E4MvcWOdzkp0iuDbntBQvycxC1JVBzf0eeO+RwJtC
EKjx6bGDLKFC5ta/28Bs6Ye8e4trlp2ow2f5qTjylDVzz/Fv07vfOV4Bm7u1dRVp
2TpADdXj/osdXOInzxTnwNCPqngsBE06GbCn76hUD4TDantq4YgaB+uZFEoBmBmk
djpr4TdS/kR896uzb3GEaGyLS3BNo6vjPruD1D0nTKNp2crN0+GOtGzJ6V5+51fp
7Fi8BjZW2VymDqgkscmRmPksd1H6Yml4uTUWjmKlpdZa1CPCDc/Pz5d2xgGAn+N3
53c+plXXdYgNkB+hFmTDLidAGoSvoEXh8R1atB+T8JhdSXoaXfJTZhR3YF8zrVkJ
T0NnZcOuDnLPQTh9J+BtWAfOXFD9FT+6YW14s79RzdNfxboPWTgiQe5ETjtO2Mp9
VDyn54CI9SG2YhV6eIJuiXO4sGDGJfLTImMIyBoRkpbZfjIRkrd2u7k3KWY0nBx3
PBNJ6CvFuiQpLMI8lmWDs4MItrSRs4Sw4OvRmxD6EzKv7rmyPBb2eOSBX3wWi592
gDngLgqTXiD3RwAPmji3uRtgImV77NYnTa9caWJ+6rN8z/CJ8SkmH3nDXkrgGP8l
LK4xHW/+WdImjmk2gHCv
=SABu
-----END PGP SIGNATURE-----

--=-K4VSOEDDhJdK1OjD0Qb1--
