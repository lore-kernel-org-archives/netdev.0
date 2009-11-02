From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 3/3] TCPCT part 1c: initial SYN exchange
 with SYNACK data
Date: Mon, 02 Nov 2009 18:04:06 +0100
Message-ID: <4AEF1106.40403@gmail.com>
References: <4AE6E35C.2050101@gmail.com> <4AE6E7C0.2050408@gmail.com> <4AEDDF33.9030205@gmail.com> <4AEECFA8.1080306@gmail.com> <alpine.DEB.2.00.0911021448280.19761@wel-95.cs.helsinki.fi> <4AEF0603.7060502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50162 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755437AbZKBREK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 12:04:10 -0500
In-Reply-To: <4AEF0603.7060502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson a =E9crit :

> It will be, when we have running code, as I'm loath to publish until =
I'm
> certain it *can* be implemented.

This is why RFC is better before coding. To avoid wasting time on exper=
iments
that have a fatal flaw. Once included in an official kernel, we wont be=
 able
to change some parameters very easily (think about 253 constant you use=
)

Or do you think only *you* can understand what's going on, and we shoul=
d
just trust you ?

>=20
> I've something like 40 RFCs published over the years.

I believe I know who you are, Mr William Allen Simpson, you dont need t=
o
repeat how much work you did in the past. This is a bit annoying.

Some patches need 6-12 months of polishing before inclusion, there is n=
othing
wrong about it. It only depends on your cooperation and patience.

And yes, even if a patch comes from Linus Torvald himself, I can talk i=
f
it does not please me.

SYNFLOOD problem is more than 13 years old, I am quite surprised its be=
coming
so urgent we should accept your patches "as is".


May I suggest to switch to normal mode, ie you prepare a next round of
patches, you submit them, we review them, [repeat 0-N time(s)], we Ack =
them ?

