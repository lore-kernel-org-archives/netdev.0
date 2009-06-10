From: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Subject: Re: [PATCH RESEND] ftrace: change the export format of	trace_kfree_skb()
Date: Wed, 10 Jun 2009 09:40:45 +0800
Message-ID: <4A2F0F1D.7010101@cn.fujitsu.com>
References: <4A2DF91F.7030906@cn.fujitsu.com> <20090609182730.GA6057@nowhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ingo <mingo@elte.hu>, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>
To: Frederic Weisbecker <fweisbec@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756842AbZFJBkd@vger.kernel.org>
In-Reply-To: <20090609182730.GA6057@nowhere>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Frederic Weisbecker wrote:

> 
> Acked-by: Frederic Weisbecker <fweisbec@gmail.com>
> 
> Would you also be interested in adding the conversion from raw numeric protocol
> to its name defined in include/linux/if_ether.h
> 
Hi Frederic:

OK, I'll do it.

> I guess __print_flags() can be used for that.
> 

Thanks for you suggestion.
IMHO, __print_symbolic() is more suitable for this. :-)

> Thanks,
> Frederic.
> 
> 
 
> 
