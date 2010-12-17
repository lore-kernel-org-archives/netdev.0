From: jamal <hadi@cyberus.ca>
Subject: Re: |PATCH net-next-2.6] ifb: use netif_receive_skb() instead of
 netif_rx()
Date: Fri, 17 Dec 2010 07:55:37 -0500
Message-ID: <1292590537.2668.7.camel@mojatatu>
References: <1292390636-3156-1-git-send-email-xiaosuo@gmail.com>
	 <1292397202.2377.13.camel@edumazet-laptop>
	 <AANLkTi=TuZNTXTBxmLqu0yyF=f0xM3CQyr_stRHerv6r@mail.gmail.com>
	 <1292402398.3427.6.camel@edumazet-laptop>
	 <1292417363.2067.17.camel@mojatatu>
	 <1292422896.3427.251.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:61900 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220Ab0LQMzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 07:55:38 -0500
Received: by yxt3 with SMTP id 3so290522yxt.19
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 04:55:37 -0800 (PST)
In-Reply-To: <1292422896.3427.251.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-15 at 15:21 +0100, Eric Dumazet wrote:
> Le mercredi 15 d=C3=A9cembre 2010 =C3=A0 07:49 -0500, jamal a =C3=A9c=
rit :

> > Eric, did you do at least a simple test on this one?=20
> > It used to be problematic (I cant remember why or
> > what use case was problematic).
>=20
> Yes, I run SFQ / IFB right now on my dev machine, and found SFQ bugs =
by
> the way ;)

Ok, thanks;->

cheers,
jamal


