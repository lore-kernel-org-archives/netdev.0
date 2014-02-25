From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] net: tcp: add mib counters to track zero window
 transitions
Date: Tue, 25 Feb 2014 13:34:11 +0100
Message-ID: <20140225123411.GC9965@breakpoint.cc>
References: <1392674268-26005-1-git-send-email-fw@strlen.de>
 <20140224.191410.698948363517952588.davem@davemloft.net>
 <20140225082341.GA9965@breakpoint.cc>
 <1393331069.2316.133.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54609 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752944AbaBYMeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 07:34:16 -0500
Content-Disposition: inline
In-Reply-To: <1393331069.2316.133.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-02-25 at 09:23 +0100, Florian Westphal wrote:
> > David Miller <davem@davemloft.net> wrote:
>  
> > > What is happening with this patch?  The discussion just died out.
> > 
> > I guess Eric is busy with TCP usec timer resolution changes.
> > You can mark the patch as defered if you want; I can re-send it for
> > 3.16 if needed.
> 
> Well, I was waiting you resend it using Hannes feedback ;)

Heh.  I was waiting for you to tell me wheter you reject the general
intention of the patch. 	Classic deadlock :)

> I am sending the cleanup for LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES
> immediately.

Thanks Eric.  I'll send v2 of the patch in a few minutes.
