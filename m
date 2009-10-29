From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: pull request: wireless-next-2.6 2009-10-28
Date: Thu, 29 Oct 2009 15:24:27 +0100
Message-ID: <1256826267.3865.112.camel@johannes.local>
References: <200910291435.54203.bzolnier@gmail.com>
	 <20091029.065336.119302168.davem@davemloft.net>
	 <200910291513.54326.bzolnier@gmail.com>
	 <20091029.072001.153801635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-qYugcg5jQ/tYUNjJ2YMW"
Cc: bzolnier@gmail.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linville@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:59084 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754729AbZJ2OYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 10:24:55 -0400
In-Reply-To: <20091029.072001.153801635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qYugcg5jQ/tYUNjJ2YMW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-10-29 at 07:20 -0700, David Miller wrote:

> In case you're concerned, I actually agree with John and others
> on this issue, and disagree with your position.

In this particular case, I think it makes more sense to duplicate the
code _especially_ because it's not working yet. That frees people
hacking on it of having to worry about breaking other devices.

johannes

--=-qYugcg5jQ/tYUNjJ2YMW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJK6aWYAAoJEODzc/N7+QmaGLoQAMcqVfkkiTG2DbNvTlJmIAvX
AIpkScm5APEDTbIamytQNBhoXe0kzCU0iW7vQU9Ztb37Mrb5sJ3c9IalxdL0rJKL
+pK0bao9cuHXJgTCqrtKae7cZQej4BdFtUJg/HiC32ScbTzMFxFBX6STVPY569XQ
A5f39ABjgLWk60eOlq62wja7YI29yVhzf2o1KPyS3Qy8/4nWrClRVGzr5lmYfh39
9fLgkJvqwrfJjWwi7vuB5W4ueqv8i9OBCSBgTELcN96F1T1rqeiKF1JbJsShRDLM
qUKRxEAwHHedu9qGLDha56o/9sYOVGR+RZ+h3zBGOIc9Idc8uzwA3twYoPL2wEJW
ua+a9aCRZKxqt4hyv9ChJ90PpdgWpblqn2Xv1Y7Ihaz44dnlklo4tN94/0kAGVYd
l1p3+4Nkb1FXUTiGJDRXP8wJOcTTr4dRB56MMP3qvXnHTbtgg0+S0EC7WajYo9Y/
N6QHk824T1qvpiQTp4fGE3VMLpnGjBDqwFpfQSahj2k+AX5aRdqnSJakNE/3O3gr
vhQM0+Q4R9EbupQw+6lzuFPPvEEYE4fOq0ku2tfkTfPCq5b3qcD+8oWK6Gj0/v3W
eqCHNzqlXLVGuz7eAwsaLuNJjjnCIdbBgburc/+gB5VxEXCpKm/6upEc34G9rU24
6jJCPx783xc3yp5XLpin
=uJlw
-----END PGP SIGNATURE-----

--=-qYugcg5jQ/tYUNjJ2YMW--

