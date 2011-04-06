From: Dmitry Novikov <dimetrios@gmail.com>
Subject: Re: Fw: [Bug 32772] New: PROBLEM: kernel BUG at net/ipv4/inetpeer.c:386
Date: Wed, 6 Apr 2011 21:15:17 +0300
Message-ID: <BANLkTinhnPR6fHRQD-vvbxX1n+Zxr=HTZw@mail.gmail.com>
References: <20110406081818.4f0489b5@nehalam>
	<1302105923.3209.103.camel@edumazet-laptop>
	<1302107123.3209.113.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49844 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754858Ab1DFSPT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 14:15:19 -0400
Received: by wya21 with SMTP id 21so1546807wya.19
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 11:15:18 -0700 (PDT)
In-Reply-To: <1302107123.3209.113.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/4/6 Eric Dumazet <eric.dumazet@gmail.com>
>
> Le mercredi 06 avril 2011 =E0 18:05 +0200, Eric Dumazet a =E9crit :
>
> >
> > This reminds me a possible memory corruption (from another layer)
> >
>
> I found the reference of a past bug report, where slub_nomerge was us=
ed
> too.
>
> =A0http://www.spinics.net/lists/netdev/msg154206.html
>
>
>
I will schedule reboot in 6 hours so that slub_nomerge parmeter been ap=
plied
