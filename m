From: Michael Neuling <mikey@neuling.org>
Subject: Re: [PATCH] gianfar: add missing include
Date: Tue, 10 Apr 2012 16:41:55 +1000
Message-ID: <10782.1334040115@neuling.org>
References: <25411.1334031527@neuling.org> <20120410063641.GA10025@localhost.localdomain>
Cc: "David S. Miller" <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, linux-next@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-reply-to: <20120410063641.GA10025@localhost.localdomain>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Cochran <richardcochran@gmail.com> wrote:
> On Tue, Apr 10, 2012 at 02:18:47PM +1000, Michael Neuling wrote:
> > This is because of a missing include file from:
> >   6663628 gianfar: Support the get_ts_info ethtool method.
> > 
> > Signed-off-by: Michael Neuling <mikey@neuling.org>
> 
> I did a poor job testing the non-x86 stuff in this series.  Thanks for
> the fix.
> 
> Acked-by: Richard Cochran <richardcochran@gmail.com>

Looks like davem fixed it before my post anyway...

http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git;a=commitdiff;h=65a85a8d4dcabe95587ab61bece38b8d58174043

This is in next-20120410.

Sorry for the noise. 

Mikey
