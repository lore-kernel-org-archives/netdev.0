From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH V3 net-next 3/4] ptp: link the phc device to its parent
 device
Date: Sat, 22 Sep 2012 10:32:41 -0700
Message-ID: <1348335161.31385.11.camel@jtkirshe-mobl>
References: <cover.1348332940.git.richardcochran@gmail.com>
	 <5cbf85cdd74396119af11ba00b4b0bcd93f23ba0.1348332941.git.richardcochran@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jHQfWlnvATukhOWEe8oP"
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43453 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753128Ab2IVRcv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2012 13:32:51 -0400
In-Reply-To: <5cbf85cdd74396119af11ba00b4b0bcd93f23ba0.1348332941.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jHQfWlnvATukhOWEe8oP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2012-09-22 at 19:02 +0200, Richard Cochran wrote:
> PTP Hardware Clock devices appear as class devices in sysfs. This
> patch
> changes the registration API to use the parent device, clarifying the
> clock's relationship to the underlying device.
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>=20

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-jHQfWlnvATukhOWEe8oP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQXfY5AAoJEOVv75VaS+3OQ7wP+wS4L5iEpJiBhZDT0u8+dy3T
+8wBa1LI8q6IG7/YRFOmpywD6WEFNct9AJy+xc27Tl+n2kjwa+SMmR64iJfTmtqf
ex1Ij2RJUHhjjTC5pB2TuHftuR/7YJ4NQusj38X9absFQLTWjztu8qTFvfddmFoF
z+A3a+aygBolxymevC8hPHChCzFNUJFfrSMEtt/zzVJpTx6T/l3ZlcGc1KpDwxqx
9ThQ9I7jLTQyEeJ35RrLHHPN4NSNnAi3l4Wk+7MWhwMtxaEr7wRrfH28WR1YrNBX
jbAR79fe3Cnsve2lzAsdRA8SgnFma97gM/pQYq/poo1Uctm2Dy9aXY3q+v4maN3m
FiYlBRBToaiCk1a+oScRA3A6tvkzvQUeG2U6/OMHtGBj7Q11rGDE8puEaK0ULSFm
vRDHa8LcjrrezTV7nD0eHjafD+xvRn4wQDtwfQGJZMhabCKCJTjVPjw0S3ove5JX
XwsiZOphfuy8LMw3VLMSCSqP+VuyNa/e8ZQwQZRup7KQuw3VGvAOJsF2bKkL7yyM
h0cv2kHzNLDa33+rfxr1AA6M26Se9DPD6PV/rvIrQJwrtw+39GumJuxpAbuZlXnx
gOyLSnhwCwYuH1+w1I4727vLGScM+p8hwFqzmp6dE9dF7poVaNNdMhUobhGy5rYj
QE9K6Z39sRph0XzJAbFn
=ZnYP
-----END PGP SIGNATURE-----

--=-jHQfWlnvATukhOWEe8oP--
