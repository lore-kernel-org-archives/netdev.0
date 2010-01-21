From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [iproute2] minor tc cleanup patches
Date: Thu, 21 Jan 2010 10:13:33 -0800
Message-ID: <20100121101333.515d3d5d@nehalam>
References: <20100112203428.GA24531@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48683 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754859Ab0AUSNi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2010 13:13:38 -0500
In-Reply-To: <20100112203428.GA24531@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Jan 2010 21:34:28 +0100
Florian Westphal <fw@strlen.de> wrote:

> Hello Stephen, hello Patrick,
> 
> here are 5 minor patches for iproute2/tc:
> the first two are small man page adjustments.
> The 3rd one makes tc print a more verbose error message instead of -EINVAL.
> 
> The 4th is a janitorial patch that removes some stale (c&p) code.
> 
> Last patch adds a man page for sched_drr.
> Patrick, it would be nice if you could have a look at this one to see
> if I got everything right (or if i forgot something important).
> 
> Thanks a lot!
> 
> Alternatively, you may pull from
> 
> git://git.breakpoint.cc/fw/iproute2.git cleanups
> 
> to obtain the following changes since commit


Applied 1-4 will wait for updated DRR man page for 5
