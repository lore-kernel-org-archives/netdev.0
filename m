From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] common receive API + r8169 use
Date: Mon, 08 Aug 2011 18:47:09 +0200
Message-ID: <1312822029.2531.5.camel@edumazet-laptop>
References: <f85e6be597ae30fd4dab776b924c0cd0a66514c0.1312314817.git.mirq-linux@rere.qmqm.pl>
	 <20110802141500.3c99185b@nehalam.ftrdhcpuser.net>
	 <20110802214349.GA17411@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45101 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330Ab1HHQrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 12:47:13 -0400
Received: by wyg24 with SMTP id 24so172153wyg.19
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2011 09:47:12 -0700 (PDT)
In-Reply-To: <20110802214349.GA17411@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 02 ao=C3=BBt 2011 =C3=A0 23:43 +0200, Micha=C5=82 Miros=C5=82a=
w a =C3=A9crit :

> I don't have fast enough transmitter yet, so have no real data. Eric'=
s
> testing showed dramatic reduction in CPU usage after changing igb to =
use
> build_skb().  Inlined version of this patch should give similar resul=
ts.
>=20
> Eric: can you share the igb changes? I have no hardware for it, but c=
ould
> merge our changes for you to test.
>=20

Hi Michal

I am just coming back from one vacation period, I'll send patches befor=
e
another one, maybe tomorrow, stay tuned ;)





