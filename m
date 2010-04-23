From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge
 amount of outgoing connections (unable to bind ... )
Date: Thu, 22 Apr 2010 19:06:21 -0700 (PDT)
Message-ID: <20100422.190621.189717402.davem@davemloft.net>
References: <20100421185837.GB21249@ioremap.net>
	<1271877975.7895.3171.camel@edumazet-laptop>
	<20100421200802.GA25130@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, greearb@candelatech.com,
	gasparch@gmail.com, netdev@vger.kernel.org
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45914
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755044Ab0DWCGQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 22:06:16 -0400
In-Reply-To: <20100421200802.GA25130@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Evgeniy Polyakov <zbr@ioremap.net>
Date: Thu, 22 Apr 2010 00:08:02 +0400

> On Wed, Apr 21, 2010 at 09:26:15PM +0200, Eric Dumazet (eric.dumazet@=
gmail.com) wrote:
>> Le mercredi 21 avril 2010 =E0 22:58 +0400, Evgeniy Polyakov a =E9cri=
t :
>>=20
>> > Damn it, I tried multiple times :)
>> > You are right of course!
>> >=20
>>=20
>> Here is a formal patch then :)
>=20
> Ack. Thank you Eric!

This code is way too complex :-)

Applied, thanks everyone!
