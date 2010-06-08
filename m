From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 v2] pkt_sched: gen_estimator: kill
 est_lock rwlock
Date: Tue, 08 Jun 2010 22:52:34 +0200
Message-ID: <1276030354.2439.8.camel@edumazet-laptop>
References: <20100608121546.GA9392@ff.dom.local>
	 <1276000052.2475.307.camel@edumazet-laptop>
	 <20100608124052.GB9392@ff.dom.local> <4C0E9A2E.9080109@gmail.com>
	 <1276026329.2439.2.camel@edumazet-laptop>
	 <20100608202405.GA3496@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61010 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700Ab0FHUwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 16:52:39 -0400
Received: by bwz11 with SMTP id 11so1306459bwz.19
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 13:52:38 -0700 (PDT)
In-Reply-To: <20100608202405.GA3496@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Such a changelog is a documentation for future, just like this one,
> crucial for this suject:
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=0929c2dd83317813425b937fbc0041013b8685ff
> 
> There is no reason to make people (our?) life harder with describing
> unexistent bugs.
> 

Now you are telling me there is no bug, and I am lying ?

> > 
> > I am really lost by your comments Jarek.
> > 
> > Maybe you could provide an alternative patch, so that we can make some
> > progress ?
> > 
> 
> No, I only meant fixing the title and changelog if you have any problem
> with separating it for two parts.

I am suggesting you rewrite this Changelog, as being part of the patch,
since I still miss your point, sorry, I must be very dumb tonight.

Then, add your Signed-off-by.

This is normal iterative process.


