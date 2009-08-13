From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/3] net: Add ftracer to help optimize process
	scheduling based on incomming frame allocations
Date: Thu, 13 Aug 2009 06:42:04 -0400
Message-ID: <20090813104204.GA16095@hmsreliant.think-freely.org>
References: <20090807202130.GA26677@hmsreliant.think-freely.org> <20090812.221515.147337283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rostedt@goodmis.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57873 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179AbZHMKmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 06:42:11 -0400
Content-Disposition: inline
In-Reply-To: <20090812.221515.147337283.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 12, 2009 at 10:15:15PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Fri, 7 Aug 2009 16:21:30 -0400
> 
> > Tested by me, working well, applies against the head of the net-next tree
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> For some reason they don't apply cleanly to net-next-2.6, probably
> because of the net-2.6 merge I did recently.
> 
> Neil, could you please respin, and also could you please not
> use the same subject line for all 3 patches?  That becomes the
> commit message header, and it should be unique for each patch
> since each patch does something different. :)
> 
> 
> 
Sure, no problem, I'll respin them all today and repost.
Thanks!
Neil

