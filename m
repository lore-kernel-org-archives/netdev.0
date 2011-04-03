From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1] net: filter: Just In Time compiler
Date: Sun, 03 Apr 2011 11:04:07 +0200
Message-ID: <1301821447.2837.127.camel@edumazet-laptop>
References: <1301783301.2837.77.camel@edumazet-laptop>
	 <20110402.224344.191403947.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, acme@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45407 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932Ab1DCJEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 05:04:14 -0400
Received: by wwa36 with SMTP id 36so5463864wwa.1
        for <netdev@vger.kernel.org>; Sun, 03 Apr 2011 02:04:13 -0700 (PDT)
In-Reply-To: <20110402.224344.191403947.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 02 avril 2011 =C3=A0 22:43 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 03 Apr 2011 00:28:21 +0200
>=20
> > In order to speedup packet filtering, here is an implementation of =
a JIT
> > compiler for x86_64
>=20
> Looks great.  Of course, everything should sit under arch/${ARCH}/ in=
 the
> end, but this is an excellent proof of concept!

Yes. The real thing would be to implement iptables as JIT ;)


