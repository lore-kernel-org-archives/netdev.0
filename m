From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [ethtool] ethtool: ixgbe DCB registers dump for 82599 and x540
Date: Fri, 08 Nov 2013 04:01:30 -0800
Message-ID: <1383912090.2365.27.camel@jtkirshe-mobl>
References: <1380787887-6878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-v5NYVNrig6CVIGJWHYWO"
Cc: Leonardo Potenza <leonardo.potenza@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Maryam Tahhan <maryam.tahhan@intel.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:63073 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753012Ab3KHMBw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 07:01:52 -0500
In-Reply-To: <1380787887-6878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-v5NYVNrig6CVIGJWHYWO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-10-03 at 01:11 -0700, Jeff Kirsher wrote:
> From: Leonardo Potenza <leonardo.potenza@intel.com>
>=20
> Added support for DCB registers dump using ethtool -d option both for
> 82599 and x540 ethernet controllers
>=20
> Signed-off-by: Leonardo Potenza <leonardo.potenza@intel.com>
> Signed-off-by: Maryam Tahhan <maryam.tahhan@intel.com>
> Acked-by: John Fastabend <john.r.fastabend@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Tested-by: Jack Morgan <jack.morgan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  ixgbe.c | 154
> ++++++++++++++++++++++++++++++++++++++++++++++++++++------------
>  1 file changed, 125 insertions(+), 29 deletions(-)

Ben-
I see you released 3.12 and I do not see this patch in your tree.  I
sent it originally on October 3rd, do need me to resend it?

--=-v5NYVNrig6CVIGJWHYWO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSfNKaAAoJEOVv75VaS+3O6TkQAJY8g4Xd/FvYRqWbh1vQ44+u
BHpsRb6u9ZJMzy9KXZHpZSqH5w/k/ZibS3xhNZPdYlkAoa4Qoq+LrIYPJsFmED42
qkW19WFnu+JSn0VVj++RbNFRASLfMpBqAdf6bxj2v603mojSSmdYziL1wBK3L0y7
BEK7NsS/M9FBHICFWrNS+UzOA882Io4hHJhPXkoxqdLoJsq2nm+m5Ynw79yN1f6r
NHHxC9oTzmxpmAT7xo0CfteyY/QR9fRYjOLDT3N7X+hOg2FfuUGwQjZ4rkTzmNNK
bEVbLVf3Jwr+WRjTWMmGOpcAa9kJowjRPwcEU1YCHC/drLaWBTNKhyE/v4jKYA3U
0D4BRqCHgqtlHDIkQG5mNha9xmDu77JcBg8OjAdsoybF0gOaCJmAt8r4sFm0iwSG
R1DucGpBnSWLL17D1sE7KErO2h0yR4YC1OS+BFDIvRcduP+3qasi2nkz50JZM0Vs
t74Qq0ZIPsnuz25dD10TSY3k4k6HBzB3QOr3T5CzXOOGtFZTO+cpjDqWTOVOdZxy
YXU0IOEiMmignacoiMTxcxz6eYGTdRFqojziuG2DuuFrXcsG6Is7ivTVTT2TSfhS
4MChCaj+bgP3eLeULraWj1RP1Fox9B/jqmULfWMeVAMI+luZaOnAjo5+6YStm6/f
2wWwuTaE19grAY5dirfw
=lLrk
-----END PGP SIGNATURE-----

--=-v5NYVNrig6CVIGJWHYWO--
