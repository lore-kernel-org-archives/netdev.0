From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: dont handle MTU reduction on LISTEN socket
Date: Tue, 19 Mar 2013 21:51:15 -0700
Message-ID: <1363755075.3333.2.camel@edumazet-glaptop>
References: <1363626088.29475.155.camel@edumazet-glaptop>
	 <alpine.DEB.2.02.1303192114580.4793@dflat>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:49673 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372Ab3CTEvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 00:51:19 -0400
Received: by mail-pd0-f176.google.com with SMTP id t12so442563pdi.35
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 21:51:18 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1303192114580.4793@dflat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-19 at 21:16 -0700, dormando wrote:

> Thanks! We are all incredibly appreciative of your quick help with this.
> 

Well, given that I introduced the bug, I better fix it ;)

> I have 3.8.3 + this patch running on our machine for 20 hours so far. We
> haven't had a kernel newer than 3.2 go for a full day before. I'm giving
> it another peak cycle before calling it dead but it looks like you nailed
> it.
> 
> I assume you no longer need the kernel disassembly?

Cross our fingers that the bug was really this one.

If you have another crash, please let us know.

Thanks !
