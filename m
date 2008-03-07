From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [PATCH 6/9] fs_enet: Be an of_platform device when CONFIG_PPC_CPM_NEW_BINDING is set.
Date: Fri, 7 Mar 2008 16:23:39 +0100
Message-ID: <200803071623.42519.laurentp@cse-semaphore.com>
References: <20070920220121.GF28784@loki.buserror.net> <200802151350.20627.laurentp@cse-semaphore.com> <1203089936.20350.7.camel@p60365-ste>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1306640.PFn9xxkKFV";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, jgarzik@pobox.com
To: Sergej Stepanov <Sergej.Stepanov@ids.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:34188 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752160AbYCGPXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 10:23:45 -0500
In-Reply-To: <1203089936.20350.7.camel@p60365-ste>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1306640.PFn9xxkKFV
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi Sergej,

On Friday 15 February 2008 16:38, Sergej Stepanov wrote:
> Am Freitag, den 15.02.2008, 13:50 +0100 schrieb Laurent Pinchart:
> > We're loosing the possibility of having MDC and MDIO on different ports.
> > This is quite easy to fix for the non-CONFIG_PPC_CPM_NEW_BINDING case b=
ut
> > I'm not familiar with OF bindings (yet) to fix the
> > CONFIG_PPC_CPM_NEW_BINDING case.
>
> for OF issue i had this for a paar month:
> http://www.spinics.net/lists/netdev/msg45778.html
> http://www.spinics.net/lists/netdev/msg47159.html
> i'll be glad if it helps...

Could these be applied ? Any showstopper ?

Best regards,

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chauss=C3=A9e de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart1306640.PFn9xxkKFV
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBH0V3+8y9gWxC9vpcRAsxrAKCM3B9Od9SMB7zGOGLifeiLypd1gwCgmG2m
k+dzZ8nQBjO5yq8g2Qo1t+s=
=dp8U
-----END PGP SIGNATURE-----

--nextPart1306640.PFn9xxkKFV--
