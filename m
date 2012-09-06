From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [ethtool 1/2] ethtool.h: implement new MDI-X set defines
Date: Thu, 06 Sep 2012 02:44:00 -0700
Message-ID: <1346924640.4228.30.camel@jtkirshe-mobl>
References: <1345538236-1636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/Q0y2b/WOBAk2gpEcIS+"
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "bhutchings@solarflare.com" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27446 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754657Ab2IFJoC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2012 05:44:02 -0400
In-Reply-To: <1345538236-1636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/Q0y2b/WOBAk2gpEcIS+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-08-21 at 01:37 -0700, Kirsher, Jeffrey T wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>=20
> These changes implement the kernel side of the interface
> for allowing drivers to set MDI-X state on twisted pair.
>=20
> Changes implemented as suggested by Ben Hutchings, thanks Ben!
>=20
> see ethtool patches titled:
> ethtool: allow setting MDI-X state
>=20
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Ben Hutchings <bhutchings@solarflare.com>
> Tested-by: Aaron Brown aaron.f.brown@intel.com
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  ethtool-copy.h | 17 +++++++++++------
>  1 file changed, 11 insertions(+), 6 deletions(-)=20

Ben - ping?  I did not see a response that you queued up this 2 patch
series for Ethtool yet.  Dave has already pulled the corresponding
kernel patches into net-next.

--=-/Q0y2b/WOBAk2gpEcIS+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQSHBgAAoJEOVv75VaS+3ONgUP/1DhviEcfAFpCewkXCOi4kNe
i6kpZBH8Z1d2NRtxmqYoYkgZPEEy/lwRbpASh1qllbUVgNNFZUxqfvn59ScuNo1d
B2ss2tdInuEymt89dHPysXahTs9ZBD+cIM3yDuxJ4nMPS8yFMcVFAuqWfKbqZTQq
CAgJ4+30owKfVVwnlBOkGexFOU9/1xrsh9YLQXMPxtAsDdW8v7xd0lYl0wuG1E97
EDeqmLASr9z60TlhVzfojXTH2JcaYFBwbDXAOG/fW/T7GLDC3QOzoIHQhOT5sgVI
ULzZyfoYhXVYnmBRE2XnvasjIOAM3H9JDJ2zZvOr+oUF4ravclHXyUMgsKVGHsSI
FVFTD2PDx2jcByfpvFl6FiiKhBe9SqQKXDGN6S1P9JHQh/FOjGVs7ltXFXM4Zh3n
q1O1798rVJh7InNTy91ccff39vAjzllFfSe8G/jGHYfpdq/1bG2j4DO9+Cf40VDK
fVn5VIy5j1NesuCiI80pP91WfQWNUXd/Zwag2pp6aWKaVXRX3EFm774u0kpnC25U
cyV5DBm/WhAxHLx+dGy4h9+ol2c6uC5dojz2le2ub5lkz5RnuUhQDSoZ7nbwCXb9
2qjjZ4cODd+CLnuOi1F3NEOAG3A/RUZvR8OWowtoG+EQ8WxCZksEdir0M943VgbK
QDXlDipoRG42iqe+V9Yz
=Me1V
-----END PGP SIGNATURE-----

--=-/Q0y2b/WOBAk2gpEcIS+--
