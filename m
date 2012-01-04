From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] e1000: unmap ce4100_gbe_mdio_base_virt in
 e1000_remove
Date: Wed, 04 Jan 2012 13:41:47 -0800
Message-ID: <1325713307.2718.35.camel@jtkirshe-mobl>
References: <1323276062-10906-1-git-send-email-ffainelli@freebox.fr>
	 <1323295282.2415.36.camel@jtkirshe-mobl> <4F04A205.4040908@freebox.fr>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2/J6avCxsb5ccIBsY9Q+"
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Florian Fainelli <ffainelli@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27070 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756992Ab2ADVlt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 16:41:49 -0500
In-Reply-To: <4F04A205.4040908@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2/J6avCxsb5ccIBsY9Q+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-01-04 at 20:01 +0100, Florian Fainelli wrote:
> Hello Jeff,
>=20
> On 12/07/11 23:01, Jeff Kirsher wrote:
> > On Wed, 2011-12-07 at 08:41 -0800, Florian Fainelli wrote:
> >> We are not unmapping ce4100_gbe_mdio_base_virt in exit path in case
> >> we are running on a CE4100 adapter, fix that.
> >>
> >> Signed-off-by: Florian Fainelli<ffainelli@freebox.fr>
> >> ---
> >>   drivers/net/ethernet/intel/e1000/e1000_main.c |    2 ++
> >>   1 files changed, 2 insertions(+), 0 deletions(-)
> >
> > Thanks Florian, I have added your two patches to my queue.
>=20
> I have not seen these patches in the last "Intel Wired LAN" pull requets=
=20
> that you did, are you holding them for a later pull request?
>=20
> Thanks.
> --
> Florian
>=20

Yes, I apologize and had overlooked your patches when putting together
the last to pull requests.  I will make sure they are in the one of the
next 2 pull requests.

--=-2/J6avCxsb5ccIBsY9Q+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPBMebAAoJEOVv75VaS+3OmbcP/2q4YIzEgzxUYMQj8OHx7YFA
HdH5lIzoqdMorY4HgtOvVMUVeOT3KsxpvJPjVL6N37zSiRFGhybxbMJ5q2rF8GCb
46ksWCzxg60tUGEStW+zdMXxrVRrmuYCk2kFRo43jjZKVPk0oybsWzwzyMJcEK/F
xntOXqNlTGyKromXSpXycofA18ryI6ZjFD5zW26xehzDAyHO9YmbV50ghgBLRnGN
QqDS4LyxU83kO8+5jmmoIPrKRsyE6WBlJQ8YAuSn7YUDgY7h8+7ER+eDc2/omKd3
IemrxlKBsXElGMIjJyzX+YmQXmwMHWdK7Ypmy4PubpbqAk2MJShjEQfACuxvssx+
tH6rWRAovCHeS82d88q4rhsKqszYNNkD7Dxe42piyC9PJuJO1BNLa209ixLzzI4U
ouVQ8gYSV0VIMJPIincUIdVwXbmMEK+dpKPy67TQqUoIJl/oLAHG3+dlokeN0bv+
hcKTYYYTNBPQrsakPt4E4mzKIDNJLAIZl1iyLoNneb4ef7hrk9ayPUoz+nCLjfaR
7y8pqhjxmuoDLmPb3WH1ZABBvaLRppFSpkcIAR/KzTFHmFI66M5yHIgUuC6bYtxj
ip7m0fpWZzWKk/SHK1v2s0KSHUeFRjd7BZNHUhF/0ypfSc8CgNtFONMeMcJETQnD
xoz1VhLH7/1gv5PTIhQY
=qkUz
-----END PGP SIGNATURE-----

--=-2/J6avCxsb5ccIBsY9Q+--
