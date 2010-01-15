From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: at91_ether.c - Allow transmitter interrupt to
 be handled first in ISR
Date: Fri, 15 Jan 2010 06:38:25 +0100
Message-ID: <4B4FFF51.6020803@gmail.com>
References: <3DBBD805E3BA064A87F551C0E8BD36740289748A@MAILSRV.intcomgrp.com> <20100113.173253.223656114.davem@davemloft.net> <3DBBD805E3BA064A87F551C0E8BD367402897539@MAILSRV.intcomgrp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: James Kosin <JKosin@intcomgrp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38714 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048Ab0AOFiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 00:38:50 -0500
In-Reply-To: <3DBBD805E3BA064A87F551C0E8BD367402897539@MAILSRV.intcomgrp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/01/2010 21:28, James Kosin a =E9crit :
> Thanks David,
>=20
> I'm checking out the latest git://git.kernel.org/pub/scm/linux/kernel=
/git/davem/net-2.6.git
> With git now...
>=20
> A few items:
> 	a)  Is it OK to use git-diff to build a patch file?  Or does everyon=
e still prefer
> 	    diff?

If you cook your patches using a git tree, git diff is very fine to sen=
d official patches.

>=20
> 	b)  I'm going to try and test also; since, I do have an active platf=
orm I
> 	    can test on.  Are there any other developers using the ARM that =
may be able
> 	    to provide some feedback?  Eric Dumazet had some interesting com=
ments
> 	    but, none of the original people in the file are around anymore =
I'm afraid.
> 	    That or they really don't want to be contacted.

If you can test patches, and other dev can review them, they can find t=
heir way in kernel,
dont worry :)
