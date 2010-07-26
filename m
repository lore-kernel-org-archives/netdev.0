From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Mon, 26 Jul 2010 22:55:04 +0200
Message-ID: <1280177704.2531.14.camel@edumazet-laptop>
References: <20100725.215548.112589000.davem@davemloft.net>
	 <20100726.130821.179918086.davem@davemloft.net>
	 <1280176743.2531.4.camel@edumazet-laptop>
	 <20100726.134826.232739122.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65062 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847Ab0GZUzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 16:55:09 -0400
Received: by wwj40 with SMTP id 40so620434wwj.1
        for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 13:55:08 -0700 (PDT)
In-Reply-To: <20100726.134826.232739122.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 juillet 2010 =C3=A0 13:48 -0700, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 26 Jul 2010 22:39:03 +0200
>=20
> > Cannot remember if I compiled v3 of the patch, to be honest.
>=20
> It's impossible that you did so, there is a missing
> closing parenthesis in the first if() statement added
> by your patch :-)

Oops

Yes, I realized this shortly after sending my previous mail :)

Thanks


