From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: Re: r8169: hard freezes on TX
Date: Tue, 5 Jun 2007 09:33:27 +0200
Message-ID: <200706050933.28046.eike-kernel@sf-tec.de>
References: <200705201520.36672.eike-kernel@sf-tec.de> <200706041506.20945.eike-kernel@sf-tec.de> <20070604214603.GA29311@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3071027.Ih6JZYPqQ1";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sf-mail.de ([62.27.20.61]:37215 "EHLO mail.sf-mail.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762831AbXFEHda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 03:33:30 -0400
In-Reply-To: <20070604214603.GA29311@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3071027.Ih6JZYPqQ1
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

You wrote:
> Rolf Eike Beer <eike-kernel@sf-tec.de> :
> [...]
>
> > I just had another freeze using your patches. After 512kB over smb it w=
as
> > dead.
>
> In-kernel smb/cifs ?

Copying to a partition mounted via smb:// protocol in konqueror which uses=
=20
kio_smb (userspace io slave).

Eike

--nextPart3071027.Ih6JZYPqQ1
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBGZRHIXKSJPmm5/E4RAjoQAKCWKVByWTDArl50ON/mAoR9Xb3rDgCfeakL
ncC7A9UIQ5SSWGCr9DVGJYk=
=16nE
-----END PGP SIGNATURE-----

--nextPart3071027.Ih6JZYPqQ1--
