From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] lockdep warning in gen_kill_estimator
Date: Wed, 08 Sep 2010 13:02:50 -0700 (PDT)
Message-ID: <20100908.130250.59696102.davem@davemloft.net>
References: <1283971234.2428.4.camel@edumazet-laptop>
	<20100908121628.0eee5294@nehalam>
	<1283973783.2428.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56390
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753632Ab0IHUCd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 16:02:33 -0400
In-Reply-To: <1283973783.2428.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 Sep 2010 21:23:03 +0200

> Le mercredi 08 septembre 2010 =E0 12:16 -0700, Stephen Hemminger a =E9=
crit :
>=20
>> But that commit adds unnecessary bh_disable
>> -------
>=20
> Yes I mentioned it in the original patch discussion

I'll apply this to net-next-2.6 after my next merge of net-2.6
into net-next-2.6
