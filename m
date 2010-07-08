From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 V2] net: fix 64 bit counters on 32 bit
 arches
Date: Thu, 08 Jul 2010 07:18:29 +0200
Message-ID: <1278566309.2543.1.camel@edumazet-laptop>
References: <1278354682.2877.639.camel@edumazet-laptop>
	 <1278360322.2466.90.camel@edumazet-laptop>
	 <20100707.143645.135512197.davem@davemloft.net>
	 <20100707.154109.26944330.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, shemminger@vyatta.com, arnd@arndb.de,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55333 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab0GHFSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 01:18:33 -0400
Received: by wyf23 with SMTP id 23so249374wyf.19
        for <netdev@vger.kernel.org>; Wed, 07 Jul 2010 22:18:32 -0700 (PDT)
In-Reply-To: <20100707.154109.26944330.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 07 juillet 2010 =C3=A0 15:41 -0700, David Miller a =C3=A9cr=
it :

> Some dev_get_stats() conversions were missing, such as parisc/led,
> some s390 code, usb rndis, etc.
>=20
> I took care of this when integrating this patch.

Thats very kind of you David, thanks !



