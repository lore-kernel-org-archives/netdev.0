From: Ben Hutchings <ben@decadent.org.uk>
Subject: ethtool 3.18 released
Date: Sun, 14 Dec 2014 19:35:11 +0000
Message-ID: <1418585711.30883.11.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-v1J4ShCVrFwcKZvI6iTp"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39472 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751202AbaLOXTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 18:19:12 -0500
Received: from [88.202.169.74] (helo=deadeye)
	by shadbolt.decadent.org.uk with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.80)
	(envelope-from <ben@decadent.org.uk>)
	id 1Y0ev0-0006Uw-Nr
	for netdev@vger.kernel.org; Mon, 15 Dec 2014 23:19:10 +0000
Received: from ben by deadeye with local (Exim 4.84)
	(envelope-from <ben@decadent.org.uk>)
	id 1Y0Ex1-0000wt-3N
	for netdev@vger.kernel.org; Sun, 14 Dec 2014 19:35:31 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-v1J4ShCVrFwcKZvI6iTp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool version 3.18 has been released.

Home page: https://www.kernel.org/pub/software/network/ethtool/
Download link:
https://www.kernel.org/pub/software/network/ethtool/ethtool-3.18.tar.xz

Release notes:

	* Fix: Lookup of SFP Tx bias in SFF-8472 module diagnostics (-m option)
	* Fix: Build with musl by using more common typedefs

Ben.

--=20
Ben Hutchings
The two most common things in the universe are hydrogen and stupidity.

--=-v1J4ShCVrFwcKZvI6iTp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVI3mgue/yOyVhhEJAQrFEg//QbkLcSw+JYKka+hwCbAbBshndoKYLMzp
OKuezbCNjBeiaiADDOKpw2BdVVnlQvVDPP2u0le3IMI4JKFRFLemNVB9OufuCarS
7TP17AIuXR2yv5zYvFXduFvLD+uxIFYj6n+sJSJuI3wR4wVVUNz+P4ohKXtBQA23
27Mp8KOZ7aa6XH406vXmcnTwraf28bAO4q8AGO3UOp4dKi4Cz7F8K6awZkU6ulLt
VsXU6goldzh6GHdfMbdLczwjCC9LhEuOUqQ9rroXJcLbxuf6FlQYREYRvdlnHFCs
hguQN31ExWfcw4j2EYFx+Q5s4F4tLMSvF7sBWFcqaOnPExmxzOPGFL1W4TWC4Z6Y
C6QlXFDGUPN0httjdNr+XHCZ2wDxNwJVlHEIKxVHp/ZJEhTvU+iusfWiaJZ0eJeC
4m+VHRw/KWrz46rNeIIk0uwWNSLNaFpYLVuBXq4DZexOf+AxKbQgexmBF/dBnYr0
eLhKmuVMpEtVygf/smXoDuyRnnHjpH+RtC+CjtSNVF0FtOjycG2wcAFFUXdsLcBe
IYuDhwcN6ikgUtCw4UKgd6J0XZvav+OrTX61Jpo17S21YhEluJrOAAQn6ZlxozBM
3xE6XHO4DCchEAVGuV2Tq1GeAwVdq/ZjjSaBa1nUCFsrPxHB3LLCNZgOC56CQvW7
Sq5A6k54m44=
=NcRF
-----END PGP SIGNATURE-----

--=-v1J4ShCVrFwcKZvI6iTp--
