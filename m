From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] ethtool: fix typo in man page
Date: Fri, 09 Oct 2015 03:24:57 +0100
Message-ID: <1444357497.2956.291.camel@decadent.org.uk>
References: <1444118856-6211-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-VWe/aVBaJizrkiCdU/te"
To: Ivan Vecera <ivecera@redhat.com>, bwh@kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36328 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934791AbbJICZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 22:25:06 -0400
In-Reply-To: <1444118856-6211-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-VWe/aVBaJizrkiCdU/te
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-10-06 at 10:07 +0200, Ivan Vecera wrote:
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> ---
>  ethtool.8.in | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/ethtool.8.in b/ethtool.8.in
> index ae56293..eeffa70 100644
> --- a/ethtool.8.in
> +++ b/ethtool.8.in
> @@ -872,7 +872,7 @@ Enables/disables the device support of EEE.
>  Determines whether the device should assert its Tx LPI.
>  .TP
>  .BI advertise \ N
> -Sets the speeds for which the device should advertise EEE capabiliities.
> +Sets the speeds for which the device should advertise EEE capabilities.
>  Values are as for
>  .B \-\-change advertise
>  .TP

Applied, thanks.

Ben.

--=20
Ben Hutchings
If the facts do not conform to your theory, they must be disposed of.
--=-VWe/aVBaJizrkiCdU/te
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVhcleee/yOyVhhEJAQpLShAA0ob9HcmfYTXen0IWNJNT7A08A5X9QaFR
kp+hHSsUxsoVMhwVv39Suq4gtAHFd/jOQYNqDpmRrivwhjkv2cyvsvbShYbimhbq
8InPi3JhN2GW5bsvXSqLHNWmHZDr6Mh2l+Sm09GdFTlHbjlp0j8iosan97E69i9Z
a8Kvb+rZL+w4uN+xpGe4r/peWjpjzIr2Ak5ZfXygKwd+LuYYWkAeuh1vEkdzPoy1
r79BzRcYvETVUofU9qiBxgE6UjZCyWZfSqAJeYddGmuC1sL49hPAVwOcBcDSycTR
G0uokNZMJ9E6GEFVgmlI1JjnyBX6G2A9jzT0GJ6MIplz2qof3ftJUHWggZlmX8YD
rop7JlIuiUlPHAmOQuq4qX61Y/DVOZvck+vjOdLVr/QomWoRswkiyodabK1fa4Ec
WD47h/I27bZyJ7rSiFvi7ycdcOdwEfHmqxnDpvMbPS78Z0LLMwWyYizDz5MaDgFt
9MxAo3ziIIErthJ3A42qNUSiQABoOUrCTfbR1noROiQ6h1EV/q6jWH+ti5VKspyw
PbrwkZQRnOS7cG6lVBLK8IrCJLApN9qI399g7whDoHzZ7od9xMHBmnTQOhD6Xuq7
qSr798UK+8cmfg6OmOnbLgpj58//tApGfnpOHLrvy90Ak9S12YCNn0L6xHJwSzg4
Jwl1x1/G/Rg=
=L6kE
-----END PGP SIGNATURE-----

--=-VWe/aVBaJizrkiCdU/te--
