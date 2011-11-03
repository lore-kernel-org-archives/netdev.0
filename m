From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: pppol2tp over pppoe NULL pointer dereference
Date: Thu, 03 Nov 2011 18:02:42 -0400 (EDT)
Message-ID: <20111103.180242.2078132551762504503.davem@davemloft.net>
References: <1320217652.30178.1.camel@edumazet-laptop>
	<CAKpUy7Y794CJkAEtbsbTecbPq+KkniSTx4ftCncohzGsuJfk-w@mail.gmail.com>
	<1320310064.2344.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: spiked.yar@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954Ab1KCWCp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 18:02:45 -0400
In-Reply-To: <1320310064.2344.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Nov 2011 09:47:44 +0100

> Le jeudi 03 novembre 2011 =E0 02:35 +0400, Misha Labjuk a =E9crit :
>> Thanks!!  Panic disappeared.
>>=20
>=20
> Here is the official patch submission again (not mangled this time),
> thanks !
>=20
> [PATCH] l2tp: fix race in l2tp_recv_dequeue()

Applied and queued up for -stable, thanks!
