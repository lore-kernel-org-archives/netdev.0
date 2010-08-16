From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Sun, 15 Aug 2010 23:21:15 -0700 (PDT)
Message-ID: <20100815.232115.13755119.davem@davemloft.net>
References: <20100814.223722.116371746.davem@davemloft.net>
	<1281936351.3683.1.camel@jlt3.sipsolutions.net>
	<1281939002.2942.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47506
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752610Ab0HPGU5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Aug 2010 02:20:57 -0400
In-Reply-To: <1281939002.2942.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 16 Aug 2010 08:10:02 +0200

> Le lundi 16 ao=FBt 2010 =E0 07:25 +0200, Johannes Berg a =E9crit :
>=20
>> I haven't gotten around to it, but Kalle had been running into the s=
ame
>> issue and said reverting it fixed it:
>>=20
>> http://article.gmane.org/gmane.linux.kernel.wireless.general/54492
>>=20
>=20
> Thanks Johannes
>=20
> Please David revert 1235f504.
>=20
> We'll find another way to address the problem.

I will, thanks guys.
