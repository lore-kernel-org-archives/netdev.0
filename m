From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net  8/8] i40e: include i40e in kernel proper
Date: Wed, 11 Sep 2013 07:32:17 -0700
Message-ID: <1378909937.2026.8.camel@jtkirshe-mobl>
References: <1378893056-4821-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1378893056-4821-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1378902002.606.42.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-OAobEs4gRwKe4x3abLD7"
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3833 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754806Ab3IKOdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Sep 2013 10:33:10 -0400
In-Reply-To: <1378902002.606.42.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OAobEs4gRwKe4x3abLD7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-09-11 at 05:20 -0700, Joe Perches wrote:
> On Wed, 2013-09-11 at 02:50 -0700, Jeff Kirsher wrote:
> > New driver build option is CONFIG_I40E
>=20
> > diff --git a/Documentation/networking/00-INDEX b/Documentation/networki=
ng/00-INDEX
> []
> > +i40e.txt
> > +	- README for the Intel Ethernet Controller XL710 Driver (i40e).
>=20
> Just curious but why the XL710 / i40e name mismatch?

i40e stands for Intel 40 GbE Ethernet which is more generic than naming
the driver the same as the first part (XL710).  That way when future
silicon is made, we are not stuck with a driver named after previous
silicon.

--=-OAobEs4gRwKe4x3abLD7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSMH7xAAoJEOVv75VaS+3OiW0P/AihzOwehZSlGJMpgAI3Qvst
wZziUUm7QmqzA3Bi2OuKK8CQSUzy9NOcOF0uIO7pM6E4ZiIWGVxXRuLcqDqBtxcu
ZqLsn+cK9auh79ap7dyAdI72OMBmF/JKu16kL/gRxh6imSx7A4itqY0lN9yjFLkf
QUjP3knR+PcXzjKUKT3NOC6572KKcW6pYmHEpBSWIuy8rscw877nQdICpcgWdwtB
hqOyB5ceO14KP32EIsavSsbYCHZyegrdpobn5dKH4s+AEG9sxemJuW0t3rVQMWLq
2yAjkixkzrCaAxZofOEuYZEnVAzQ29h31IIycO/ThMYiCj/QbzUB9x2trrrx27VR
NXc7L6TjIRzMH+sMPxIVR+k+FL9i9IGpCh7bI6AcUgQ+PXyxLBt4k7aexU2B0pB6
Fd3SbQ8kHTpegDFEBCvZUVQQHLXMjSiruKkkjEDaL2F7Q9Hyzb9AoQLfdsyPRA64
VZDsrWIZ6mzWgLOsNk9xGKPW5zC45vpxpfl7htiIH2V7uYrH7TAXL+ZmqUlEnqO4
RgAJ3T2w1KEixMssWZJC2rf0pPcuPQyiaD4kwOxdcdOumDpGrpsckqG2KdLLFERC
6HyfhRwwphjjXS9gg7Fto0K6DEjwSCXKHt6c4vN7k+bBTzWIhYBIedXppBEi6D0h
BQwl52+kvIDcNk3HaocC
=eByQ
-----END PGP SIGNATURE-----

--=-OAobEs4gRwKe4x3abLD7--
