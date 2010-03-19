From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: speedup netdev_set_master()
Date: Thu, 18 Mar 2010 23:11:43 -0700 (PDT)
Message-ID: <20100318.231143.52206723.davem@davemloft.net>
References: <1268976491.2894.221.camel@edumazet-laptop>
	<20100318.223658.241427584.davem@davemloft.net>
	<1268977513.2894.223.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39090
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750865Ab0CSGLV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Mar 2010 02:11:21 -0400
In-Reply-To: <1268977513.2894.223.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 Mar 2010 06:45:13 +0100

> Le jeudi 18 mars 2010 =E0 22:36 -0700, David Miller a =E9crit :
>> It was not an issue of related, but rather "B won't apply cleanly
>> without A". Even line offsets can make "git apply" reject.
>> --
>=20
> I see, I can resubmit later if you prefer, once net-2.6 fix is pulled=
 in
> net-next, there is no hurry :)

No need, just let me know about this stuff in the future, that's
all :-)
