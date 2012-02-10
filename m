From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/3] netprio_cgroup: some miscelaneous off by one fixes
Date: Fri, 10 Feb 2012 15:28:36 -0500
Message-ID: <20120210202836.GA23529@hmsreliant.think-freely.org>
References: <1328888618-16208-1-git-send-email-nhorman@tuxdriver.com>
 <20120210.150907.2078843825154966709.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lizf@cn.fujitsu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37864 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932440Ab2BJU2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 15:28:43 -0500
Content-Disposition: inline
In-Reply-To: <20120210.150907.2078843825154966709.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2012 at 03:09:07PM -0500, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Fri, 10 Feb 2012 10:43:35 -0500
> 
> > About 2 weeks ago, Li Zefan posted a series of cleanups and fixes for cls_cgroup
> > and netprio_cgroup.  It was requested that the cleanups and fixes be separated
> > into two different series and reposted.  Its been about 2 weeks, and after
> > pinging the author a few times and getting no response, I've decided to repost
> > the fixes for netprio myself, as they're important and I don't want them to be
> > forgotten or otherwise fall through the cracks.
> > 
> > Origionally-authored-by: Li Zefan <lizf@cn.fujitsu.com>
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com
> > CC: Li Zefan <lizf@cn.fujitsu.com>
> > CC: "David S. Miller" <davem@davemloft.net>
> 
> All applied, thanks Neil.
Thanks!
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
