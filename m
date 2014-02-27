From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/2] gitignore: ignore test-driver
Date: Thu, 27 Feb 2014 22:53:58 +0000
Message-ID: <1393541638.14067.74.camel@deadeye.wl.decadent.org.uk>
References: <1393464911-21593-1-git-send-email-f.fainelli@gmail.com>
	 <1393464911-21593-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-HiF7cZLMa+7peuB8XjyA"
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46658 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751296AbaB0WyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 17:54:03 -0500
In-Reply-To: <1393464911-21593-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-HiF7cZLMa+7peuB8XjyA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-02-26 at 17:35 -0800, Florian Fainelli wrote:
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  .gitignore | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/.gitignore b/.gitignore
> index 45c95015df1b..b03b56f88132 100644
> --- a/.gitignore
> +++ b/.gitignore
> @@ -13,6 +13,7 @@ ethtool.spec
>  ethtool.8
>  ethtool
>  test-cmdline
> +test-driver
>  test-features
>  stamp-h1
>  config.*

Applied, thanks.

Ben.

--=20
Ben Hutchings
It is easier to change the specification to fit the program than vice versa=
.

--=-HiF7cZLMa+7peuB8XjyA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUw/CBue/yOyVhhEJAQoRYA/6A9tVNYM3m8bim6nI97OAr9tGiq34KGsO
cOBBKXdSG3bflEfHnPVTSwAo4NGNZkDO8vCseNXorCcs7XDRoH0y7eooUF/yNKM/
q0uPePU5S4Q5OJdN1IDX1TUwXjFpqz9ik7sdlG1LYILXj0T9M1/rw7qjZGO01n5U
D5JoSQ+qGiDwtPNNLxOdMTL8vmIiMh7ZI+8UMIYuJIy6xugkNsGbo3/5tePMh1hd
A51ANC6ml/eYJnXoTchURZ1j4W7VKqJahewS8SaPRki6fPAS9oUMiwcqLtx0+1/5
Wp3N04Jw5GS/3jlnnLhLYOd000IhBug16uLmCpN4pGynIpb2aU0FzSax0fjB4vR+
NdFYXUYYRag7AYpgaj0Z8BYlY4HtvkB9glcCWfU1HFMmpD7NIQFs5chB7Pm8zy2Y
XU26QL40JN0MKXFxvbhTFDFzHsLMLjwRTACWtSvKo6OlRyWos8d/DkFSOQr6NF02
mJhfSzV7nD5qtgrW8UuJJ6K8XQYnRIgcjd4Y4Sl+hFYsvPClM47Qu1B5ozt8+xAl
B6Y46WWSlUQow3jf8Z5h6LahhHS/LvokHd3GWt3sWlykdmpRZWJUdNXcTw88OSi0
OEYptUULlBBMRrDoI2vLu0nChxZSIefLG5CRvJvLhnFxeyl+ry6UQk356aU9s5Ac
ZwiBIyKH3og=
=hCnW
-----END PGP SIGNATURE-----

--=-HiF7cZLMa+7peuB8XjyA--
