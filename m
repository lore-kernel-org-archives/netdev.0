From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: Soft lockups with dscape on wireless-dev tree
Date: Tue, 23 Jan 2007 13:57:50 -0500
Message-ID: <200701231357.54921.flamingice@sourmilk.net>
References: <9e4733910701230910w79a7af45hff626e48a7091ffd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1321760.Z0ijs9e7fO";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:20209 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965428AbXAWS6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 13:58:23 -0500
To: "Jon Smirl" <jonsmirl@gmail.com>
In-Reply-To: <9e4733910701230910w79a7af45hff626e48a7091ffd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1321760.Z0ijs9e7fO
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday 23 January 2007 12:10, Jon Smirl wrote:
> I've hit this twice. This time I unplugged my USB hub which had the
> device in it.
>
Please try the patch I posted earlier:

http://marc.theaimsgroup.com/?l=linux-netdev&m=116841004113998&w=2

Also can be found here:

http://kernel.org/git/?p=linux/kernel/git/jbenc/dscape.git;a=commitdiff_plain;h=e3973cb079b24875af1f196d03569ce7eb517c92;hp=f85c9f7b6a0fe662b95595c51aed92d784e93c5e

-Michael Wu

--nextPart1321760.Z0ijs9e7fO
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFtlqyT3Oqt9AH4aERAvxBAJ9K/zaGsQpKqQtW8FVukmcvKsCULwCfS7Us
c3IbJXig3xlq2m87KBbvnzs=
=TSHi
-----END PGP SIGNATURE-----

--nextPart1321760.Z0ijs9e7fO--
