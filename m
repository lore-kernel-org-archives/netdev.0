From: Mihai Moldovan <ionic@ionic.de>
Subject: Re: iproute2 regression -- ss -u returns an empty list
Date: Tue, 28 Apr 2015 15:14:31 +0200
Message-ID: <553F87B7.7090602@ionic.de>
References: <553EE0D9.3050601@ionic.de> <20150428112108.GA22108@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="uwN9MNwgEdAxBLUPL3i3hlT8uLOjoCWpN"
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from powered.by.root24.eu ([5.135.3.88]:37799 "EHLO Root24.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965549AbbD1NOd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 09:14:33 -0400
In-Reply-To: <20150428112108.GA22108@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--uwN9MNwgEdAxBLUPL3i3hlT8uLOjoCWpN
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

Hi Vadim,


On 28.04.2015 01:21 PM, Vadim Kochan wrote:
> Seems I have a fixed version, I tested it localy with different
> option combinations, and now there should be no issues when specifying
> different families.

Thanks for the quick work! I'm happy to test.


> Would you be able to test it ? How I can provide a fixed version to you=
 -
> by patch or I can push to my github and give you a link ?

I don't mind, any way is fine. I can work either way.



Mihai



--uwN9MNwgEdAxBLUPL3i3hlT8uLOjoCWpN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCgAGBQJVP4e3AAoJEB/WLtluJTqH3eoQAN6hCtz6WcdVG1XWURs1WtFO
aeX+wcl/YWSktUc01tlSWfhZTZYcxuhP8c8Tq4T/aw070Hps9WNlo6IvNl/H7YQE
7x03IdmarpAWIoIZFYMhzn1ymD7hCTZagE428b/TAQRx2vSg9rSj46KtqGDVrums
qP/LLUhAlw09agKqNQtFTzFQ9jHjVlouGXBksrbdQT8wXRvss4PlVTORAB3BIgUg
EDNVbz+gkCNqjIK6/YqlhuVYAnVtnbvNxa9u2ipbVCmqUuacmRiPoAx26A1OIT3S
PA12QU9J1qwNLx6fvx2QqupaZJXH/AqmLVMDwuKWZbeM8BkvMvN+7JW64r3iYznH
bu8x1tmmwzc9duQJHxhLd2QP07kw+j0w8PMhx6p45NFs5w/BYn+0szeQm0cI+4Hd
+K9wmYoM8daWSLvNYDdvsi4yGVnE20u0asH/8GF2OXa9b/2OCg+L6R5ijyFYSY7g
cevWO9LKzY00rD5pfgTw3XDvwLF10xCP+w2nFqEm3vdOdwUULllYnfImWxj83RZ3
+vsshFGQoSLj6GW+slIKJdP3GMDKIOhG8kguyAfsgJ9PV6Yzf7ZiTQzEvsj2W2Qn
rktE1bUM+gBIAXGdzBHx5eUVMOGD9qguKysSxqdYVvQimnb6BGaRmpRnTz3R3j/Z
4ePHUwPtd2KXUWlb3s+v
=Y/Sd
-----END PGP SIGNATURE-----

--uwN9MNwgEdAxBLUPL3i3hlT8uLOjoCWpN--
