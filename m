From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 v4] net_sched: SFB flow scheduler
Date: Thu, 24 Feb 2011 08:18:19 +0100
Message-ID: <1298531899.2898.24.camel@edumazet-laptop>
References: <1298390536.2861.9.camel@edumazet-laptop>
	 <1298474091.3301.364.camel@edumazet-laptop>
	 <1298494577.2898.9.camel@edumazet-laptop>
	 <20110223.140614.112607341.davem@davemloft.net>
	 <1298526035.2898.20.camel@edumazet-laptop>
	 <20110223225143.30226902@nehalam>
	 <1298531670.2898.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Juliusz.Chroboczek@pps.jussieu.fr, linville@tuxdriver.com,
	kaber@trash.net, netdev@vger.kernel.org, andi@firstfloor.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57630 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932559Ab1BXHSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:18:33 -0500
Received: by bwz15 with SMTP id 15so778209bwz.19
        for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:18:32 -0800 (PST)
In-Reply-To: <1298531670.2898.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 24 f=C3=A9vrier 2011 =C3=A0 08:14 +0100, Eric Dumazet a =C3=A9=
crit :
> Le mercredi 23 f=C3=A9vrier 2011 =C3=A0 22:51 -0800, Stephen Hemminge=
r a =C3=A9crit :
> > Where is the iproute (q_sfb) piece?
> >=20
> >=20
>=20
> I'll send it this morning after polishing.
>=20
> As a matter of fact, I might add Patrick idea to use nested attribute=
s,
> before official SFB release.
>=20

BTW, one can use old iproute (tc command) for SFB with default params.




