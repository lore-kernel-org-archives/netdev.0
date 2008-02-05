From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [PATCH 00/24 for-2.6.25] DM9000 updates for 2.6.25
Date: Tue, 5 Feb 2008 10:52:08 +0100
Message-ID: <200802051052.11334.laurentp@cse-semaphore.com>
References: <20080205000159.432081941@fluff.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1631587.1N1spfvE8B";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, akpm@linux-foundation.org,
	daniel@caiaq.de
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:1679 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753651AbYBEJvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 04:51:45 -0500
In-Reply-To: <20080205000159.432081941@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1631587.1N1spfvE8B
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 05 February 2008 01:01, Ben Dooks wrote:
> This patch set is a series of updates for the DM9000
> driver, to tidy-up some of the source, stop the accesses
> to the PHY and EEPROM sitting and spinning with locks
> held, and to add ethtool support.
>
> This set includes a pair of patches from Laurent Pinchart
> for addition platform-data based configuration, please
> apply these from this if you can attribute these correctly
> to Laurent, otherwise ask Laurent to resubmit. I have
> signed-off-by both these patches, but would be equally
> happy acking them.

If you can apply the patches without a resubmission that's of course less w=
ork=20
for me :-) Otherwise I can resubmit them.

> The only missing item in this series is to replace the
> old timer based polling code. This series has been sitting
> long enough on my own trees, and having MII link status
> reports is not a driver-threatening bug.
>
> Hopefully this series meets up to everyone's approval and
> can be applied whilst the current merge window is upon us.

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chauss=C3=A9e de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart1631587.1N1spfvE8B
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBHqDHL8y9gWxC9vpcRAmSIAJ9Ybx+m+W7+wsrkXafaGhm6tC2oqgCgs2Bg
YPkVjirhuocypTOumP3pdRw=
=SQR4
-----END PGP SIGNATURE-----

--nextPart1631587.1N1spfvE8B--
