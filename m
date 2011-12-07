From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2] e1000e: Assign true and false to bool type variable
 instead of 1 and 0
Date: Wed, 07 Dec 2011 01:19:59 -0800
Message-ID: <1323249599.2415.32.camel@jtkirshe-mobl>
References: <4EDED071.40900@linux.vnet.ibm.com>
	 <1323229439.2415.23.camel@jtkirshe-mobl>
	 <1323231268.1762.19.camel@joe2Laptop> <4EDEF05F.4020901@linux.vnet.ibm.com>
	 <1323237700.1762.24.camel@joe2Laptop> <4EDF02CC.4010407@linux.vnet.ibm.com>
	 <1323238749.1762.27.camel@joe2Laptop> <4EDF0964.3080509@linux.vnet.ibm.com>
	 <1323248664.2415.28.camel@jtkirshe-mobl>
	 <4EDF2EBE.2060708@linux.vnet.ibm.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2NxrZ+LfgbCzwNWlq0vT"
Cc: Joe Perches <joe@perches.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wangyunlinux@gmail.com" <wangyunlinux@gmail.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28079 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751714Ab1LGJUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 04:20:01 -0500
In-Reply-To: <4EDF2EBE.2060708@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2NxrZ+LfgbCzwNWlq0vT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-12-07 at 01:15 -0800, Michael Wang wrote:
> On 12/07/2011 05:04 PM, Jeff Kirsher wrote:
>=20
> > On Tue, 2011-12-06 at 22:36 -0800, Michael Wang wrote:
> >> On 12/07/2011 02:19 PM, Joe Perches wrote:
> >>
> >>> On Wed, 2011-12-07 at 14:08 +0800, Michael Wang wrote:
> >>>> I'm not good at script, if you are interested, we can work together
> >> to
> >>>> fix all the remain cases, and send out some patches.
> >>>
> >>> You should try coccinelle and spatch.
> >>>
> >>
> >> Hi, Joe
> >>
> >> I have not used coccinelle and spatch before, I will study on them
> >> later.
> >>
> >>> If you run the script, this is the intel output.
> >>>
> >>>  drivers/net/ethernet/intel/e1000/e1000_main.c |   10 +++++-----
> >>>  drivers/net/ethernet/intel/ixgb/ixgb_main.c   |    2 +-
> >>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
> >>>  drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c  |    4 ++--
> >>>  4 files changed, 9 insertions(+), 9 deletions(-)
> >>
> >>
> >> We can try to fix them, thanks for the suggestion.
> >>
> >> Regards,
> >> Michael Wang=20
> >=20
> > So should I expect a v3 of this patch?
> >=20
>=20
> Hi, Jeff
>=20
> Please use the v2 first, because what Joe described will have a
> different meaning and edit different files.

Ok sounds fine to me.

>=20
> > Also I am fine with lumping all the changes for all our drivers in one
> > patch as long as the changes for each driver are somewhat small.  If th=
e
> > changes for a particular driver gets too extensive, please create a
> > separate patch.
>=20
>=20
> I think separate such patch according to files will be better.
>=20
> Thanks,
> Michael Wang
>=20
> >=20
> > Cheers,
> > Jeff
>=20
>=20



--=-2NxrZ+LfgbCzwNWlq0vT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJO3y+/AAoJEOVv75VaS+3O4aAP/00MI8kGpq8vqRf9TSyBFR/2
3sGiRv7SGA79m0Dqh1zu++XdF200ehpnrwXYGOrEm2bXYxOcpLNwb8DebbD8bKZR
8QNvAPxCYGNX/kklWTYGP2IK1lLVCS7jgGydUmaSfMBUHe3EGWLvg/s0zJuYS4am
sEEAXjU0UJn/S8NZMPBLo1LZqXMnSGtk8ko8VkkKZoTAUsh8SjDzj+YK2oF5O6cK
NJBtRrfq/kKxsRQnP43Djpro8xat0J8vSInADv7GtRwO4e43iY62S4fkLK9F1aZF
MILajaXUnqDWV0Sk8L0LZE49OftHzPxH+NjLGEsasMU8xPv3d373AqtPcmex/eX+
spxtKDmxGoH+rPRS2LTbY1EXiCq91eCHKd6M9AvilHslil5dWxQRzKfi9jMDMU4x
Vzj2BaRFSA9q4c3WFtN6lFjnkkaTuk/xSue2BdZ+VHGu4ipGw85YZF1rSUAD9+e1
AF350oAimlh52XTIXvIFP++QkDGMjBSuwqkgDK4MKfTr0QYq+B2A05HAZ6TgB7T+
s21CC/o6La5As0AIiSnrlYWBfAOHqkM249eBjA8wnIm/8NPlYywzqSxeYlJDf218
/s3lgDAF8hti74UR7Wjra9zG8ASfyYZv4POq9yhTVNp1EqT8+YfKz1FCycwmyiiI
pqoautNn2wCLdPgpaAos
=hyie
-----END PGP SIGNATURE-----

--=-2NxrZ+LfgbCzwNWlq0vT--
