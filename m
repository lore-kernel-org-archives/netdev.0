From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] dst: call cond_resched() in dst_gc_task()
Date: Tue, 09 Feb 2010 07:07:42 +0100
Message-ID: <1265695662.4236.96.camel@edumazet-laptop>
References: <4B701CA8.7050205@itcare.pl>
	 <1265639549.3048.33.camel@edumazet-laptop>
	 <1265657560.4236.80.camel@edumazet-laptop>
	 <20100208.150126.25065601.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pstaszewski@itcare.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:44704 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334Ab0BIGHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 01:07:46 -0500
Received: by bwz19 with SMTP id 19so490500bwz.28
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2010 22:07:45 -0800 (PST)
In-Reply-To: <20100208.150126.25065601.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 f=C3=A9vrier 2010 =C3=A0 15:01 -0800, David Miller a =C3=A9=
crit :

>=20
> When fixing bugs with kernel bugzilla entries, please
> mention them in the commit message.  I fixed this up for
> you but please take care of it next time.
>=20
> Thanks!

Sorry Dave, I was not aware of the bugzilla entry.


