From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] atm: remove a net_device_stats clear
Date: Thu, 19 Aug 2010 00:15:13 -0700 (PDT)
Message-ID: <20100819.001513.212394625.davem@davemloft.net>
References: <20100818083304.2ef2eea4@nehalam>
	<20100818.131043.226780154.davem@davemloft.net>
	<1282164274.2328.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, tklauser@distanz.ch, linux@arm.linux.org.uk,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	kernel-janitors@vger.kernel.org, error27@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38215
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750999Ab0HSHO4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 03:14:56 -0400
In-Reply-To: <1282164274.2328.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Aug 2010 22:44:34 +0200

> Le mercredi 18 ao=FBt 2010 =E0 13:10 -0700, David Miller a =E9crit :
>> Yep, both the ether1 and ether3 patch have this problem.  Looks
>> like we'll see v4 coming some :-)
>=20
> To be fair, we accepted some bits like that in the past ;)

Yes, but let's nip it in the butt immediately when we do
notice it :-)

> [PATCH net-next-2.6] atm: remove a net_device_stats clear
>=20
> No need to clear device stats in lec_open()
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks!
