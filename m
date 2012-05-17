From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/4][pull request] Intel Wired LAN Driver Updates
Date: Thu, 17 May 2012 04:51:18 -0700
Message-ID: <1337255478.2714.50.camel@jtkirshe-mobl>
References: <1337254070-32500-1-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qcI0xhrZRK9z6kVNtBy+"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:64121 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761630Ab2EQLvU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 07:51:20 -0400
In-Reply-To: <1337254070-32500-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qcI0xhrZRK9z6kVNtBy+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-05-17 at 04:27 -0700, Jeff Kirsher wrote:
> This series of patches contains updates for e1000, e1000e and igb.
>=20
> The following are changes since commit dc6b9b78234fecdc6d2ca5e16291857182=
02bcf5:
>   net: include/net/sock.h cleanup
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
>=20
> Bruce Allan (1):
>   e1000e: fix typo in definition of E1000_CTRL_EXT_FORCE_SMBUS
>=20
> Matthew Vick (1):
>   igb: Disable the BMC-to-OS Watchdog Enable bit for DMAC.
>=20
> Sebastian Andrzej Siewior (2):
>   e1000: remove workaround for Errata 23 from jumbo alloc
>   e1000: look in the page and not in skb->data for the last byte
>=20
>  drivers/net/ethernet/intel/e1000/e1000_main.c  |   30 ++++--------------=
------
>  drivers/net/ethernet/intel/e1000e/defines.h    |    2 +-
>  drivers/net/ethernet/intel/igb/e1000_defines.h |    2 +
>  drivers/net/ethernet/intel/igb/igb_main.c      |    3 ++
>  4 files changed, 11 insertions(+), 26 deletions(-)
>=20

v2 of the series will be coming.

--=-qcI0xhrZRK9z6kVNtBy+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPtOY2AAoJEOVv75VaS+3OgHsP/3iTfdN3CFTCC17NtD8bS/j1
y+isvNDtyKEMUTQweNbhr9R/fM9tnA678i/zChMt+Bkt05VGMQS+EWbpr+oEpuCR
Xpfwy3nZQVHM+IkbLHgd3UDTug21X4Q8b9j0pG0+rD0aJx/GyA/QcFTMMb4EVmlH
jIeadTK0Wq3AXdCVDMUfZzGcyYb55HHlpear6Y0CmUHPUkOxoE/Ze/kcAKri54nN
pdtQuWjhtZ4QAWL373l2qptc6cmFI6dhvf6t33Wly8ATRs/FMVtby9Tra1xwVhh/
6cnEtZafGVGSk/Ar4BPTQWtn/MxcrqPrK6wIyg4oqjWGsQLEF2s/ZjIX1Pm7LQqA
+ZEKHbKbPWH32n5yMVvWbrSvwlHiOPmIKdtreir2khtQdknfpE/4myMP9iO1+G1L
CfVl57A2SmKUbzznW4HBLIKWPVd1usQTh2zr86RgL/uoGAOFS2DncZNb8NJFHgUI
LLHzYIqUaKvfF+64UlQrYVx1Zv1qBWhkOX11G0ZpnGbXy3k6GnzqJ9iVq1M6cK7Y
KYZctJlhxgYJY5zjpxNsv7IW+TWQYMJ0lYkcradhdfsL5qgB45TRsObhZOtHfBoQ
QTV/anrxFJa14fwqQIlOJVpJsDpFHVlEjfHliwIXfIl6S+6fBdMWil47ESUtmQqE
Vz8Cr4f7lI4bKTuelkLL
=JGC9
-----END PGP SIGNATURE-----

--=-qcI0xhrZRK9z6kVNtBy+--
