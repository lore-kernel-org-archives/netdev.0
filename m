From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] remove an outdated reference to T/TCP
Date: Wed, 07 Dec 2011 09:58:07 +0100
Message-ID: <1323248287.2690.41.camel@edumazet-laptop>
References: <20111206200005.836D529006DD@tardy>
	 <20111206.151920.696192671128392379.davem@davemloft.net>
	 <4EDE8B8B.2000907@hp.com>
	 <20111206.164243.402402261622724566.davem@davemloft.net>
	 <CAK6E8=cne1UbOEcZ6ZfsJw-=qwUsO=yMEi3LNNsTpM_5crv0fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48973 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753931Ab1LGI6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 03:58:12 -0500
Received: by eekd41 with SMTP id d41so234285eek.19
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2011 00:58:11 -0800 (PST)
In-Reply-To: <CAK6E8=cne1UbOEcZ6ZfsJw-=qwUsO=yMEi3LNNsTpM_5crv0fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 d=C3=A9cembre 2011 =C3=A0 15:00 -0800, Yuchung Cheng a =C3=A9=
crit :

> I am fine keeping the comment as is.  This does remind me to put more
> comments on this part of the code in our upcoming Fast Open patch :)

This sounds great.

Is TFO patch using inetpeer cache to store cookies ?

(I ask this because TFO paper I read mentions linux-2.6.34, I presume
you couldnt use inetpeer at that time since it was IPv4 only)
