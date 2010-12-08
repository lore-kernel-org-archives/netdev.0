From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: RCU conversion of dev_getbyhwaddr() and
 arp_ioctl()
Date: Wed, 08 Dec 2010 19:11:41 +0100
Message-ID: <1291831901.2883.67.camel@edumazet-laptop>
References: <1291548233.2806.212.camel@edumazet-laptop>
	 <20101208.100528.193703457.davem@davemloft.net>
	 <1291831654.2883.66.camel@edumazet-laptop>
	 <20101208.101035.226775926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maximlevitsky@gmail.com, linux1394-devel@lists.sourceforge.net,
	stefanr@s5r6.in-berlin.de, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45052 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755801Ab0LHSLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 13:11:46 -0500
Received: by wwa36 with SMTP id 36so1460358wwa.1
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 10:11:45 -0800 (PST)
In-Reply-To: <20101208.101035.226775926.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 d=C3=A9cembre 2010 =C3=A0 10:10 -0800, David Miller a =C3=
=A9crit :

> I know about the conflict and will resolve it when I do a merge in
> the next hour or so.
>=20
> Don't worry about this.

Ah thats great, thanks !



