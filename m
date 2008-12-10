From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used jiffies in
	htb_dequeue()
Date: Wed, 10 Dec 2008 09:11:26 +0000
Message-ID: <20081210091126.GA4707@ff.dom.local>
References: <20081209130803.GB15353@ff.dom.local> <493E7080.5060308@trash.net> <20081209144534.GC15353@ff.dom.local> <20081209.223545.196224587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, devik@cdi.cz, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:45966 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993AbYLJJLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 04:11:34 -0500
Received: by ewy10 with SMTP id 10so519842ewy.13
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2008 01:11:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081209.223545.196224587.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 09, 2008 at 10:35:45PM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Tue, 9 Dec 2008 14:45:34 +0000
> 
> > To David Miller: David don't apply yet - this patch needs change.
> 
> What I've done is apply patches 5 and 6 since those are
> fine and independent of these timer issues.

Very nice of you, but IMHO patches 1 and 4 are OK too.

I'm withdrawing patches 2 and 3, and will try to discuss this with
Patrick more, but this could stay like this too.

> So once you work this stuff out please resubmit the rest.

Of course, I can resubmit 1 and 4 if you think it's really needed.

Thanks,
Jarek P.
