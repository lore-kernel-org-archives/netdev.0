From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 10/17] e1000e: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:04:20 -0700
Message-ID: <1396119860.2287.32.camel@jtkirshe-mobl>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
	 <a424de4ff88dd10f1c1d77747b47477020c68d26.1396090802.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-yGNMF98IwfpiCdv8hn+z"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:20153 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546AbaC2TEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Mar 2014 15:04:36 -0400
In-Reply-To: <a424de4ff88dd10f1c1d77747b47477020c68d26.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yGNMF98IwfpiCdv8hn+z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-03-29 at 12:26 +0100, Francois Romieu wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)

Thanks Francois, I have added your patch to my queue.

--=-yGNMF98IwfpiCdv8hn+z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTNxk0AAoJEOVv75VaS+3OFmoQAImytctqUhNy0XZidwKLAcKk
Ax3fYd+PZTj5OMtoyY0EdFY1GLb9/+1Jg8/m2VO/GpZnJOH94S9DGe+1YTgfliEM
9GYfPPf8IvSVBoRJnvCncLZ/gXLLgCHwyZZuKJa0q40mkXyM+Kdz6RHKHK3mlJWm
UeiCmUfYeoCsZsHeZsBY/KjGGyjTgEPTeLrsRpvagGX7qxc/4Dhjd47Q5VmQSnv7
n/tGOQf+S3aoC2rLl7ktI9qaH6XyoLqVMvODl6YwR0AY1IXaaM7MAHL6iP03sror
enKamjtOZSsFvaOHPu5jsClI7QtfeR9YKAAWKRkVgBgGPW2wvG2hSWzBFm4ZyqZc
FDH7jPxkQ7tVkRPlWsRGAGHsOjs+/4QsMrU1YyaPkh0NgShbNVRNqE/NNeLOwZlk
I+RYiUX53YAM+ggvTDWsN/OxjY9QRpunhHNFMETGAdYGLfGeQRm3iwanb0pTl5vx
tH/LtO+XESUbBd8exX1rAfFbQLKU/dFb7DhWU1q3795vBMSciSBF/3/GCF0ZfyFg
jiHlQlxQphLed72FY3k0Ovg7vIYyp9HT8nuEqxjw8wEtj/YnK8ES9AZIibTZlSYS
yFQjYKlKEfWsr7H6Fe8eW/WZ3JTHxwR6yFRJwlgpiQ5TRFByqk35mshKd+jy7Y9s
4k1l/hd0LevzmOzlIpt9
=kscB
-----END PGP SIGNATURE-----

--=-yGNMF98IwfpiCdv8hn+z--
