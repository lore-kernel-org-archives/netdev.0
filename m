From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ipip: get rid of ipip_lock
Date: Wed, 15 Sep 2010 23:31:52 +0200
Message-ID: <1284586312.2462.74.camel@edumazet-laptop>
References: <1284571676.2462.20.camel@edumazet-laptop>
	 <1284583777.2462.33.camel@edumazet-laptop>
	 <20100915.142943.13758184.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64531 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753409Ab0IOVb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 17:31:58 -0400
Received: by wyf22 with SMTP id 22so706099wyf.19
        for <netdev@vger.kernel.org>; Wed, 15 Sep 2010 14:31:57 -0700 (PDT)
In-Reply-To: <20100915.142943.13758184.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 septembre 2010 =C3=A0 14:29 -0700, David Miller a =C3=A9=
crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>

> > While doing ip_gre conversion, I realize I should define a new help=
er
> ...
> > I'll submit a patch serie :
> >=20
> > 1/3) net: add rtnl_dereference
> > 2/3) ipip: get rid of ipip_lock
> > 3/3) gre: get rid of ipgre_lock
>=20
> Ok.

And a 4/4) sit: get rid of ipip6_lock

;)



