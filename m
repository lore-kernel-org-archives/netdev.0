From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [RFC PATCH] common receive API + r8169 use
Date: Fri, 26 Aug 2011 20:44:13 +0200
Message-ID: <20110826184413.GA15188@rere.qmqm.pl>
References: <f85e6be597ae30fd4dab776b924c0cd0a66514c0.1312314817.git.mirq-linux@rere.qmqm.pl>
 <20110802141500.3c99185b@nehalam.ftrdhcpuser.net>
 <20110802214349.GA17411@rere.qmqm.pl>
 <1312822029.2531.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:52320 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751086Ab1HZSoO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Aug 2011 14:44:14 -0400
Content-Disposition: inline
In-Reply-To: <1312822029.2531.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 08, 2011 at 06:47:09PM +0200, Eric Dumazet wrote:
> Le mardi 02 ao=C3=BBt 2011 =C3=A0 23:43 +0200, Micha=C5=82 Miros=C5=82=
aw a =C3=A9crit :
> > I don't have fast enough transmitter yet, so have no real data. Eri=
c's
> > testing showed dramatic reduction in CPU usage after changing igb t=
o use
> > build_skb().  Inlined version of this patch should give similar res=
ults.
> >=20
> > Eric: can you share the igb changes? I have no hardware for it, but=
 could
> > merge our changes for you to test.
> I am just coming back from one vacation period, I'll send patches bef=
ore
> another one, maybe tomorrow, stay tuned ;)

Still tuned in, but receiving no signal. ;-)

Best Regards,
Micha=C5=82 Miros=C5=82aw
