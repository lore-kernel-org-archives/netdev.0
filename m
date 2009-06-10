From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH RESEND] ftrace: change the export format of
	trace_kfree_skb()
Date: Wed, 10 Jun 2009 09:26:19 +0200
Message-ID: <20090610072618.GA6016@nowhere>
References: <4A2DF91F.7030906@cn.fujitsu.com> <20090609182730.GA6057@nowhere> <4A2F0F1D.7010101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo <mingo@elte.hu>, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>
To: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:41730 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbZFJH0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 03:26:20 -0400
Content-Disposition: inline
In-Reply-To: <4A2F0F1D.7010101@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2009 at 09:40:45AM +0800, Xiao Guangrong wrote:
> 
> 
> Frederic Weisbecker wrote:
> 
> > 
> > Acked-by: Frederic Weisbecker <fweisbec@gmail.com>
> > 
> > Would you also be interested in adding the conversion from raw numeric protocol
> > to its name defined in include/linux/if_ether.h
> > 
> Hi Frederic:
> 
> OK, I'll do it.


Thanks!


> 
> > I guess __print_flags() can be used for that.
> > 
> 
> Thanks for you suggestion.
> IMHO, __print_symbolic() is more suitable for this. :-)


Heh, indeed :)

 
> > Thanks,
> > Frederic.
> > 
> > 
>  
> > 

