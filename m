From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH stable 3.11+] can: bcm: add skb destructor
Date: Wed, 29 Jan 2014 07:48:43 -0800
Message-ID: <1391010523.28432.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52E833ED.4080006@hartkopp.net>
			<1390953066.28432.26.camel@edumazet-glaptop2.roam.corp.google.com>
			<52E8B053.2030808@gmail.com>
		 <20140128.234630.1768378245126172951.davem@davemloft.net>
		 <52E8C03A.4030906@gmail.com>
	 <1391007225.28432.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52E91FD8.90402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, socketcan@hartkopp.net,
	netdev@vger.kernel.org
To: Andre Naujoks <nautsch2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:47299 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764AbaA2Psp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 10:48:45 -0500
Received: by mail-pb0-f49.google.com with SMTP id up15so1896938pbc.36
        for <netdev@vger.kernel.org>; Wed, 29 Jan 2014 07:48:44 -0800 (PST)
In-Reply-To: <52E91FD8.90402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-29 at 16:35 +0100, Andre Naujoks wrote:

> I am not resisting to anything. I was just *irritated* about the way
> this was handled. Since Oliver is already trying to fix this, any
> further discussion here is meaningless anyway.

I sent a patch, because I thought the fix was obvious, but last attempt
from Oliver was way too complex for a backport.
