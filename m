From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug#708995: iptables firewall is dropping GRO'd packets
Date: Tue, 21 May 2013 06:22:06 -0700
Message-ID: <1369142526.3301.208.camel@edumazet-glaptop>
References: <20130520044850.31127.24148.reportbug@shadbolt.decadent.org.uk>
	 <1369096123.3469.127.camel@deadeye.wl.decadent.org.uk>
	 <1369097605.3301.203.camel@edumazet-glaptop>
	 <1369101790.3301.206.camel@edumazet-glaptop>
	 <20130521125502.GA7374@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>, 708995@bugs.debian.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:44149 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753196Ab3EUNWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 09:22:08 -0400
Received: by mail-pa0-f47.google.com with SMTP id kl13so708594pab.20
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 06:22:08 -0700 (PDT)
In-Reply-To: <20130521125502.GA7374@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-21 at 14:55 +0200, Jiri Pirko wrote:

> This is looking good to me. On my test machine it makes tbf work correctly
> with gso packets.
> I worked on similar patch (enqueue path) myself some time ago but I got
> distracted by other tasks.

Yes, I understood this.

> 
> Do you plan to submit this patch?
> 

Of course I will, when correctly tested.
