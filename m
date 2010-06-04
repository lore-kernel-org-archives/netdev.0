From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: net/socket.c and net/compat.c
 cleanups
Date: Fri, 04 Jun 2010 05:36:27 +0200
Message-ID: <1275622587.2533.92.camel@edumazet-laptop>
References: <1275575381.2456.71.camel@edumazet-laptop>
	 <20100603.200529.183035231.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53059 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756931Ab0FDDgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 23:36:32 -0400
Received: by wyi11 with SMTP id 11so552317wyi.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 20:36:30 -0700 (PDT)
In-Reply-To: <20100603.200529.183035231.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 juin 2010 =C3=A0 20:05 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 03 Jun 2010 16:29:41 +0200
>=20
> > cleanup patch, to match modern coding style.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> It's modern, except for that trailing empty newline you added at
> EOF of net/socket.c which GIT warns about and I had to fix.

Oh... thanks for the tip and fix !


