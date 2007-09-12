From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH]: xfrm audit calls
Date: Wed, 12 Sep 2007 14:56:41 -0400
Message-ID: <30135.1189623401@turing-police.cc.vt.edu>
References: <200709120003.l8C03E4G004949@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1189623401_2979P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com, davem@davemloft.net
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:46307 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357AbXILS5P (ORCPT
	<RFC822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 14:57:15 -0400
In-Reply-To: Your message of "Tue, 11 Sep 2007 19:03:14 CDT."
             <200709120003.l8C03E4G004949@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1189623401_2979P
Content-Type: text/plain; charset=us-ascii

On Tue, 11 Sep 2007 19:03:14 CDT, Joy Latten said:
> This patch modifies the current ipsec audit layer
> by breaking it up into purpose driven audit calls.
>
> So far, the only audit calls made are when add/delete
> an SA/policy.

What other audit calls do you envision adding in the future?

--==_Exmh_1189623401_2979P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFG6DZpcC3lWbTT17ARAjRgAKDXwrShGo/emYn5IQD6QT4k2qQaWwCfdtvq
lmktbR3zqkpxifGKRaXDHAo=
=vWPT
-----END PGP SIGNATURE-----

--==_Exmh_1189623401_2979P--
