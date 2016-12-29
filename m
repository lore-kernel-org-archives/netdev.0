From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: Re: [PATCH v4] net: dev_weight: TX/RX orthogonality
Date: Thu, 29 Dec 2016 20:53:10 +0100
Message-ID: <dd06fa90-2891-bc33-3c47-d185cef95cfd@gmx.net>
References: <20161229.140854.1456743873101323068.davem@davemloft.net>
 <1483039398-28017-1-git-send-email-matthias.tafelmeier@gmx.net>
 <20161229.144456.2187353715676829840.davem@davemloft.net>
 <20161229.144555.1740958763290967121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha384;
 protocol="application/pgp-signature";
 boundary="8ltchCxo5rm9fTfWrdFpJBTvk9GRbAI5f"
Cc: netdev@vger.kernel.org, hagen@jauu.net, fw@strlen.de,
        edumazet@google.com, daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:52850 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750794AbcL2Txg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Dec 2016 14:53:36 -0500
In-Reply-To: <20161229.144555.1740958763290967121.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--8ltchCxo5rm9fTfWrdFpJBTvk9GRbAI5f
Content-Type: multipart/mixed; boundary="3pjQbL5TrFovKElVV6uTvBmjKlRRAono6";
 protected-headers="v1"
From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, hagen@jauu.net, fw@strlen.de,
 edumazet@google.com, daniel@iogearbox.net
Message-ID: <dd06fa90-2891-bc33-3c47-d185cef95cfd@gmx.net>
Subject: Re: [PATCH v4] net: dev_weight: TX/RX orthogonality
References: <20161229.140854.1456743873101323068.davem@davemloft.net>
 <1483039398-28017-1-git-send-email-matthias.tafelmeier@gmx.net>
 <20161229.144456.2187353715676829840.davem@davemloft.net>
 <20161229.144555.1740958763290967121.davem@davemloft.net>
In-Reply-To: <20161229.144555.1740958763290967121.davem@davemloft.net>

--3pjQbL5TrFovKElVV6uTvBmjKlRRAono6
Content-Type: multipart/mixed;
 boundary="------------07E360DB1E1208CD4E1A0734"

This is a multi-part message in MIME format.
--------------07E360DB1E1208CD4E1A0734
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


> Actually, reverted, you didn't even build test this:
>
> net/core/dev.c:3433:35: error: initializer element is not constant
>  int dev_rx_weight __read_mostly =3D weight_p;
>                                    ^~~~~~~~
> net/core/dev.c:3434:35: error: initializer element is not constant
>  int dev_tx_weight __read_mostly =3D weight_p;
>                                    ^~~~~~~~

Thought I would have ... let me check.


--------------07E360DB1E1208CD4E1A0734
Content-Type: application/pgp-keys;
 name="0x8ADF343B.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="0x8ADF343B.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2

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
qnlCR0LVNOnSE3Eb
=3D0oZJ
-----END PGP PUBLIC KEY BLOCK-----

--------------07E360DB1E1208CD4E1A0734--

--3pjQbL5TrFovKElVV6uTvBmjKlRRAono6--

--8ltchCxo5rm9fTfWrdFpJBTvk9GRbAI5f
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBCQAGBQJYZWmmAAoJEOAWT1uK3zQ7r30IAMO2FWbGBHAtJJq19IgxQ2dy
yxYM6mYMFeX3XzuwNrC+HG7eI5VLsO5gqUCreDzZUmvA1cTIgVAUZEzTfMAW035X
KE7mAM4VktXIiPbddCpy/276ylZUxOrim74CBM9ZP+oBwVS8mOUBCay76FDD5nQ4
Y0wiamuqAZW/YJh7YjygRHpjiPrRIBPojQytgihjyTsq7dNbBOlW99+mHhpSsOgG
9KLB2s38kKjYEixscI8jT2YbPZ3C+B87o14LgFtP+lnWo7RUYFX1p1cwbBvyY3b4
ThCEVypRwCghCd4SoozLsJkWzCwQn2MEpp3Tb6RlxorULCBw4NBmpZakp0Ym+SM=
=tqt/
-----END PGP SIGNATURE-----

--8ltchCxo5rm9fTfWrdFpJBTvk9GRbAI5f--
