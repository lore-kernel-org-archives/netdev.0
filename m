From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] net: ethernet: intel: i40e: i40e_fcoe.c:  Remove unused
 function
Date: Wed, 31 Dec 2014 15:15:35 -0800
Message-ID: <1420067735.31582.90.camel@jtkirshe-mobl>
References: <1420044537-21077-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-znfp226TldZk+lZADMli"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:29726 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143AbaLaXPh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2014 18:15:37 -0500
In-Reply-To: <1420044537-21077-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-znfp226TldZk+lZADMli
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-12-31 at 17:48 +0100, Rickard Strandqvist wrote:
> Remove the function i40e_rx_is_fip() that is not used anywhere.
>=20
> This was partially found by using a static code analysis program
> called cppcheck.
>=20
> Signed-off-by: Rickard Strandqvist
> <rickard_strandqvist@spectrumdigital.se>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_fcoe.c |    9 ---------
>  1 file changed, 9 deletions(-)

Thanks Rickard!  I thought I had some patches in my queue that started
to make use of that function, but come to find out, I don't... :-)

I will add your patch to my queue, thanks!

--=-znfp226TldZk+lZADMli
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUpIOXAAoJEOVv75VaS+3OWMsP/1rsarCCjudStqCyW5hOv/hg
3P5yTHs6kS9aLePShPcKPBoclKuA+bW7tfzl6J1Uh/jMOuGqpcN0ps5fAOkzKisa
Tv/doVLyEAOJk9qHkQDnod42HvBpjU0p6+Tn3nSPI+vINEWpEIc7IEs6CkLm6gvf
e1c7nD8KqT0NrTg/7pd82XxLnHgqIG9Y12shGz3ZUD5LzLx9yOlfuUtTP7tfhsge
i0BDPaUiqmJCwPvll2TZZ8mV65Igx4TiL69ve1LX0HkyF57kSVEwb0vD+I8g2DGq
mTVETuz/oKMnJjwmkmbMXktNMZLs0NNDwbqxx++wzhGhd09l307CiEBI1Dzw0wC5
NyPgeyTwFMtLLjjv1KBUouWS5Y6E1sAzC6jiSFHv7izQJ5UMeWyzKSsHftgXq643
FGVNoHQ39DPpwCVoacggEbLrU9YKHhB9yoqHWENFOmkgQOi1al5gewCvdbcX4vxh
a7y1qg4m95mfjwEoqioAVNcl9geibqc1eM6NCl9ipAVyxI0LOe11VYLr/P4mUk55
5rZFVuNMirqdV1MXWRAK4TRD4dBAIeMaFEtcpm0gfN9inpK3+yEJRNqq7OYBaqX4
vcIFlbWlQDxTVmo46p0aS0r2HUPwTa6cSnowWevV2myaVlIWZ5UX+Uq3cT5TwePD
POvfkYEIXjcbC8Ri3kWd
=TOEW
-----END PGP SIGNATURE-----

--=-znfp226TldZk+lZADMli--
