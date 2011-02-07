From: Noah Meyerhans <frodo@morgul.net>
Subject: iputils license issue
Date: Sun, 6 Feb 2011 23:38:04 -0800
Message-ID: <20110207073804.GN23882@morgul.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NzB8fVQJ5HfG6fxh"
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.morgul.net ([128.31.0.48]:55415 "EHLO minas.morgul.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752841Ab1BGI0D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Feb 2011 03:26:03 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello.  In ac3fe58b (in the iputils git repo on linux-ipv6.org), code
was added to ping6.c that makes use of some routines from OpenSSL's
libcrypto library.  No explicit licensing is attached to this code, so
due to the concerns about mixing GPL code with OpenSSL code, I'm seeking
clarification about the terms under which it may be distributed.  The
original heading for ping6.c indicates that the file is licensed under
the BSD license.  If the intent is for this new code to also be BSD
licensed, could you state this in the copyright statement in ping6.c?
If the intent was for the code to be licensed under the GPL, would you
be willing to grant an exception similar to the example at
http://lists.debian.org/debian-legal/2002/07/msg00454.html

Thanks.
noah


--NzB8fVQJ5HfG6fxh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQFNT6FcYrVLjBFATsMRAlY4AJ4pV3NVH7fOQuahakUUJaU/PoKuAwCfdW6N
FFxl1eQQE/86cHw7Y8WWlqc=
=uMQQ
-----END PGP SIGNATURE-----

--NzB8fVQJ5HfG6fxh--
