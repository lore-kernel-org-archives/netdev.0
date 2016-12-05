From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH net-next 3/3] net: ethoc: Demote packet dropped error
 message to debug
Date: Mon, 5 Dec 2016 09:00:37 +0100
Message-ID: <20161205080037.GH18069@ulmo.ba.sec>
References: <20161204204030.9853-1-f.fainelli@gmail.com>
 <20161204204030.9853-4-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="ISKrrfpKsPiF35CV"
Cc: netdev@vger.kernel.org, tremyfr@gmail.com, tklauser@distanz.ch,
        davem@davemloft.net, andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:33372 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751100AbcLEIAk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 03:00:40 -0500
Received: by mail-wj0-f194.google.com with SMTP id kp2so37860145wjc.0
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 00:00:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161204204030.9853-4-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ISKrrfpKsPiF35CV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Dec 04, 2016 at 12:40:30PM -0800, Florian Fainelli wrote:
> Spamming the console with: net eth1: packet dropped can happen
> fairly frequently if the adapter is busy transmitting, demote the
> message to a debug print.
>=20
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/ethoc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Acked-by: Thierry Reding <thierry.reding@gmail.com>

--ISKrrfpKsPiF35CV
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAABCAAGBQJYRR6kAAoJEN0jrNd/PrOhVTwP/j5eKt1/fXjZuQ7LwUlPRkC1
K360HSiXx271JyQIYH1CtlsniQTSY9BDiR3h8LpXgslIOazD2+mhCIR0JHXXpF3T
9cxFWbK/wuE+aHw+uYqG6I/3TsgxXo5OTgsJUbOUz3nZfU/sd3qXU1KDK4W6sMHt
ffRTkgPB8OykBbguDSqLNm2uD6KMDgUOXN12JPvLd/l6cnRPc/ct8M4V3Sv/szn7
R5jfxy90IHvSQUwmSiQgF4NSHbCF7Ri1f8OyFT9olxwclSMAtGpDoHuCFlc6XpGw
1ErotOtGoCt5zEsLtjBGzw44kqeuPXJ80Q8egPlA8Ih44IIbzdasdGzE7kzOxrXE
DepiJhMNshzyQw3+W1BcnGLzJ5NlDthRJo/NOXUYsCAqECkwW1i344gVDnYLxysA
BKJy8dJHntaSuVO41EaD53TIRBDERD4j3mwoMlia+7SOmYK+Xsu4G839XXpW2D2u
1SEjrpEB/nM8EVUo6n9XpTRdM3mAlq7ZpY+eYy++yp9n5vff5EByrlpmktwHeoSP
bKsEP/3GgpmXekXFANcSGQAVqI4DA4b1ZyV5OBj/omScvlp3SGZk2pAkN+nkF3Zz
l/612pfOhdQo1/wm6Qll4EXrEr6XUMxRVMaZf6Q9Nm2j+9jpIpKrr87KUq7FAcmp
XzHpdIwb5uMLyOCucENU
=7BqG
-----END PGP SIGNATURE-----

--ISKrrfpKsPiF35CV--
