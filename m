From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] TCP_USER_TIMEOUT: a new socket option to specify max
 timeout before a TCP connection is aborted
Date: Mon, 30 Aug 2010 22:30:12 +0200
Message-ID: <1283200212.2405.14.camel@edumazet-laptop>
References: <AANLkTimW_7a9=yK4po9FshH0i0LT-MZF+fysGRvgT3jG@mail.gmail.com>
	 <20100829.211954.232753860.davem@davemloft.net>
	 <AANLkTinrPcJwMs+frY7J_QKuNv1MDGRQAgPgwofuFydw@mail.gmail.com>
	 <20100830.132502.68138403.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hkchu@google.com, hannemann@nets.rwth-aachen.de, hagen@jauu.net,
	lars.eggert@nokia.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50203 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754939Ab0H3Uad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 16:30:33 -0400
Received: by wyb35 with SMTP id 35so7023462wyb.19
        for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 13:30:31 -0700 (PDT)
In-Reply-To: <20100830.132502.68138403.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 30 ao=C3=BBt 2010 =C3=A0 13:25 -0700, David Miller a =C3=A9cri=
t :

> I was just saying that it can result in unexpected situations.  The
> user can increase and increase the timeout they use, but to no effect
> because due to backoff the increase isn't adding any more probes at
> all.
>=20
> In any event, I've applied your patch, let's see how this goes.



Jerry, could you please send a man update ?

http://www.kernel.org/doc/man-pages/online/pages/man7/tcp.7.html

(To Michael Kerrisk <mtk.manpages@gmail.com> )

Thanks


