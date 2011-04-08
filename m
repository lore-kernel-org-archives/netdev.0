From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: convert to hw_features
Date: Thu, 07 Apr 2011 20:17:46 -0700 (PDT)
Message-ID: <20110407.201746.226777024.davem@davemloft.net>
References: <20110331110135.9625513A68@rere.qmqm.pl>
	<20110406.124843.28805522.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50692
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757358Ab1DHDSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 23:18:23 -0400
In-Reply-To: <20110406.124843.28805522.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Miller <davem@davemloft.net>
Date: Wed, 06 Apr 2011 12:48:43 -0700 (PDT)

> From: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
> Date: Thu, 31 Mar 2011 13:01:35 +0200 (CEST)
>=20
>>>From the code it looks like the hardware might support full HW_CSUM =
not
>> just IP_CSUM.  This needs testing and so is not changed here.
>>=20
>> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
>=20
> Stephen, did you get a chance to test this patch like you said you
> would?

I don't see any value in waiting any longer, so I've applied this patch=
=2E

