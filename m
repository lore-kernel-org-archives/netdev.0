From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: fix for new ndo_get_stats64 signature
Date: Wed, 07 Jul 2010 22:41:14 -0700 (PDT)
Message-ID: <20100707.224114.223470222.davem@davemloft.net>
References: <1278555085-17074-1-git-send-email-dm@chelsio.com>
	<1278566230.2543.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dm@chelsio.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49483
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750810Ab0GHFlA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jul 2010 01:41:00 -0400
In-Reply-To: <1278566230.2543.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Jul 2010 07:17:10 +0200

> Le mercredi 07 juillet 2010 =E0 19:11 -0700, Dimitris Michailidis a
> =E9crit :
>> The change to ndo_get_stats64 in "net: fix 64 bit counters on 32 bit=
 arches"
>> missed cxgb4.  Fix it.
>>=20
>> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
>> ---
>=20
> Indeed, sorry and thanks !
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
