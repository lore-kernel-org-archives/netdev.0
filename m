From: Thadeu Lima de Souza Cascardo <cascardo@cascardo.eti.br>
Subject: Re: [PATCH 1/1] Update maintainer for EHEA driver.
Date: Mon, 18 Jul 2016 14:38:45 -0300
Message-ID: <20160718173844.GL7287@siri.cascardo.eti.br>
References: <1468862925-21730-1-git-send-email-dougmill@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BI5RvnYi6R4T2M87"
Cc: netdev@vger.kernel.org
To: Douglas Miller <dougmill@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trem.minaslivre.org ([148.251.208.85]:47408 "EHLO
	grilo.cascardo.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457AbcGRRod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 13:44:33 -0400
Content-Disposition: inline
In-Reply-To: <1468862925-21730-1-git-send-email-dougmill@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--BI5RvnYi6R4T2M87
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 18, 2016 at 12:28:45PM -0500, Douglas Miller wrote:
> Since Thadeu left IBM, EHEA has gone mostly unmaintained, since his email
> address doesn't work anymore.  I'm stepping up to help maintain this
> driver upstream.
>=20
> I'm adding Thadeu's personal e-mail address in Cc, hoping that we can
> get his ack.
>=20
> CC: Thadeu Lima de Souza Cascardo <cascardo@cascardo.eti.br>

Acked-by: Thadeu Lima de Souza Cascardo <cascardo@cascardo.eti.br>

> Signed-off-by: Douglas Miller <dougmill@linux.vnet.ibm.com>
> ---
>  MAINTAINERS |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 1d74837..e9cefe2 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -4477,7 +4477,7 @@ S:	Orphan
>  F:	fs/efs/
> =20
>  EHEA (IBM pSeries eHEA 10Gb ethernet adapter) DRIVER
> -M:	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
> +M:	Douglas Miller <dougmill@linux.vnet.ibm.com>
>  L:	netdev@vger.kernel.org
>  S:	Maintained
>  F:	drivers/net/ethernet/ibm/ehea/
> --=20
> 1.7.1
>=20

--BI5RvnYi6R4T2M87
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXjRQkAAoJEAq6ZQNy/ZVxqDYP/0naDwDGGyZoElngPB0O7k6e
J6+r8a+V0NXoV3gCOtqeF55Q62cY1TbmHRu9kDv0IQdnJFWeWvKsCyoRL5h1ZEdD
4Mj+Cg9V6wNpJ9eGwwGvxlnXlcKFx4ewGPqdPblxy8s3unFK98ZsvDZA1q37nkom
D8jmMXmZv8bDruDxIjimZxEqwQRk+zGQVA6ft+5krpbJwQ852pmmBvuVEZhpK5WB
BSI/vEs3TtugpDe14BwS3iTnZElvEcP9NXOilMQvGuTKKeEzQCT0vmdzFDX2kB1P
VnEL10s/+fPND3xWOQJ95RFfwAzFW1bsyKHxI5AGmiBOPCyndrNCEj7HiQ7+yKHi
ulboKLUI4tRNcUV/EbKuxVd5dpbKYc61XNmf66LkvY3Hi05oTor91sKf1qR2eVHV
bKIyg5DP9pLfOfUvt6kb5nUO2C0RbF0DvXFi+lS/0KQjQNfKwfp4t4Td2BU72pRE
GSHkW3dnGxo9LCncTo1PIJybcP6F8OTYf/lvo0j2iaTaotyFbOj1/DVLa8ee+LH7
ykxQpSJYz5GThE+1JoIxaBqG5RrEHh4fx+NgTPfWl5KYFTLMP5dXeYGYE1qDjXkZ
pVjKHvm1Gow/Yi8whvfoLkq5EmZk5JBGX4N/Ozg1+AwciuaiFFuW5jPB8o8G1nZG
lO3fEthCk1zG9dh/jZk0
=PAj5
-----END PGP SIGNATURE-----

--BI5RvnYi6R4T2M87--
