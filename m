From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] 2.6.37-rc5 Memory leak in net/ipv4/udp.c
Date: Fri, 17 Dec 2010 15:22:07 +0100
Message-ID: <1292595727.2906.14.camel@edumazet-laptop>
References: <19723.14557.349975.821418@ipc1.ka-ro>
	 <1292582116.2906.5.camel@edumazet-laptop>
	 <19723.17775.241784.993744@ipc1.ka-ro>
	 <1292585534.2906.12.camel@edumazet-laptop>
	 <19723.19914.961119.861405@ipc1.ka-ro>
	 <19723.20449.974043.309608@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Lothar =?ISO-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41195 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755046Ab0LQOWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 09:22:11 -0500
Received: by wyb28 with SMTP id 28so665853wyb.19
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 06:22:10 -0800 (PST)
In-Reply-To: <19723.20449.974043.309608@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 d=C3=A9cembre 2010 =C3=A0 12:56 +0100, Lothar Wa=C3=9Fma=
nn a =C3=A9crit :

> Forget about this. I was a little confused when reading the
> alloc_large_system_hash() function. No I understand.

Any idea why you got a small allocation ?

How much LOWMEM do you have on your platform ?


