From: Valdis.Kletnieks@vt.edu
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Fri, 11 Apr 2008 15:58:47 -0400
Message-ID: <22897.1207943927@turing-police.cc.vt.edu>
References: <47FEADCB.7070104@rtr.ca> <20080410.172453.44434205.davem@davemloft.net> <47FEB062.3020003@rtr.ca> <20080410.173911.179180620.davem@davemloft.net> <47FEBDAA.7010305@rtr.ca> <Pine.LNX.4.64.0804110849520.28360@wrl-59.cs.helsinki.fi> <47FF6555.50004@rtr.ca> <20080411143537.GA27874@2ka.mipt.ru>
            <47FF7CED.9090601@rtr.ca>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1207943927_4539P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	=?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	tilman@imap.cc, yoshfuji@linux-ipv6.org,
	Jeff Garzik <jeff@garzik.org>, rjw@sisk.pl,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Mark Lord <lkml@rtr.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:45028 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757321AbYDKUG5 (ORCPT
	<RFC822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 16:06:57 -0400
In-Reply-To: Your message of "Fri, 11 Apr 2008 10:59:57 EDT."
             <47FF7CED.9090601@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1207943927_4539P
Content-Type: text/plain; charset=us-ascii

On Fri, 11 Apr 2008 10:59:57 EDT, Mark Lord said:

> The one thing I did not have time for initially,
> was a painstaking blunt instrument binary search of
> every commit since v2.6.24.

The nice thing about binary search is that it's by definition an
O(log2(N)) operation, which isn't bad at all as far as algorithms go.

The truly blunt instrument here would be a linear search of every commit...



--==_Exmh_1207943927_4539P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFH/8L3cC3lWbTT17ARAqJAAKC17YoTbNXtjO74Cjix2TH8lXnMEgCgxEhM
zVFXyJR40oOzhDfY/4004+k=
=DXhx
-----END PGP SIGNATURE-----

--==_Exmh_1207943927_4539P--
