From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH RESEND] ftrace: change the export format of
 trace_kfree_skb()
Date: Tue, 9 Jun 2009 21:56:32 -0400 (EDT)
Message-ID: <alpine.DEB.2.00.0906092156140.30552@gandalf.stny.rr.com>
References: <4A2DF91F.7030906@cn.fujitsu.com> <20090609182730.GA6057@nowhere> <4A2F0F1D.7010101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Frederic Weisbecker <fweisbec@gmail.com>, Ingo <mingo@elte.hu>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>
To: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.124]:41728 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754459AbZFJB4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 21:56:31 -0400
In-Reply-To: <4A2F0F1D.7010101@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 10 Jun 2009, Xiao Guangrong wrote:

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
> 
> > I guess __print_flags() can be used for that.
> > 
> 
> Thanks for you suggestion.
> IMHO, __print_symbolic() is more suitable for this. :-)

BTW, you might want to take a look at what is coming:

  http://marc.info/?l=linux-kernel&m=124458472931447&w=2

-- Steve

