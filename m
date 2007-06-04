From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: Re: r8169: hard freezes on TX
Date: Mon, 4 Jun 2007 15:06:15 +0200
Message-ID: <200706041506.20945.eike-kernel@sf-tec.de>
References: <200705201520.36672.eike-kernel@sf-tec.de> <20070522202934.GA21991@electric-eye.fr.zoreil.com> <200705230848.33299.eike-kernel@sf-tec.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5371482.F1XPMhcfuS";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.sf-tec.de ([62.27.20.187]:49758 "EHLO mail.sf-mail.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751795AbXFDNGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 09:06:22 -0400
In-Reply-To: <200705230848.33299.eike-kernel@sf-tec.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5371482.F1XPMhcfuS
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Rolf Eike Beer wrote:
> Francois Romieu wrote:
> > Rolf Eike Beer <eike-kernel@sf-tec.de> :
> > [...]
>
> Ok, just tested. I used a file of 200MB and copied it to another host on
> the LAN. If I used our 100 MBit switch nothing happened. When I put a 10
> MBit hub in the middle it died at 77 MB.

I just had another freeze using your patches. After 512kB over smb it was=20
dead.

Eike

--nextPart5371482.F1XPMhcfuS
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBGZA5MXKSJPmm5/E4RAmAIAJ9p7Ff9nhWZBczfCbn/ojUXofaZegCcC8S7
n4+F1p2rcZBSnMNQFDBgbJ4=
=f2iJ
-----END PGP SIGNATURE-----

--nextPart5371482.F1XPMhcfuS--
