From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH wireless-dev] add p54 driver
Date: Tue, 17 Oct 2006 11:51:15 -0400
Message-ID: <200610171151.20363.flamingice@sourmilk.net>
References: <200610171105.34912.flamingice@sourmilk.net> <1161099828.5668.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1978242.maHBl908WG";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:56162 "EHLO
	annwn13.rutgers.edu") by vger.kernel.org with ESMTP
	id S1751134AbWJQPwW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 11:52:22 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1161099828.5668.7.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1978242.maHBl908WG
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday 17 October 2006 11:43, Dan Williams wrote:
> On Tue, 2006-10-17 at 11:05 -0400, Michael Wu wrote:
> > The attached patch adds support for 3887 based prism54 usb wireless
> > adaptors. It is partially based on the islsm driver by Jean-Baptiste
> > Note, but most of the code is new (and uses d80211 instead of madwifi).
> > It doesn't work perfectly yet, but it can connect to an unsecure AP and
> > send/receive packets as long as you don't hit the tx code too hard.
> > Further hardware support for pci and net2280 usb will follow later. Also,
> > I am unable to make it crash. Thus, it should be in a suitable state for
> > other developers to hack on.
>
> I'm assuming this is for the softmac prism54 chipset, right?
>
Yes.

-Michael Wu

--nextPart1978242.maHBl908WG
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFNPv4T3Oqt9AH4aERAn3sAJ9ZFknHbc/FrN0WWeN2NDIYqGV+LACeMm/e
WIEuFDNfG3+nvUgpJQYUuxQ=
=EE7/
-----END PGP SIGNATURE-----

--nextPart1978242.maHBl908WG--
