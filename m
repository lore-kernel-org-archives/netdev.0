From: David Miller <davem@davemloft.net>
Subject: Re: small RPS cache for fragments?
Date: Mon, 06 Jun 2011 12:23:08 -0700 (PDT)
Message-ID: <20110606.122308.2278752934695697100.davem@davemloft.net>
References: <20110604.132940.2214949964968775365.davem@davemloft.net>
	<1307380132.8149.2718.camel@tardy>
	<1307380513.3098.76.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57389 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757795Ab1FFTXP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 15:23:15 -0400
In-Reply-To: <1307380513.3098.76.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Jun 2011 19:15:13 +0200

> Le lundi 06 juin 2011 =E0 10:08 -0700, Rick Jones a =E9crit :
>=20
>> Mode-rr bonding reorders TCP segments all the time.=20
>=20
> Shouldnt TCP frames have DF bit set ?

That has nothing to do with this discussion :-)

DF bit set or not, TCP or UDP, this bonding mode apparently reorders
frames all the time.
