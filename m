From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/3] netprio_cgroup: some miscelaneous off by one fixes
Date: Wed, 15 Feb 2012 06:49:19 -0500
Message-ID: <20120215114919.GA21312@hmsreliant.think-freely.org>
References: <1328888618-16208-1-git-send-email-nhorman@tuxdriver.com>
 <4F3B16E4.5020507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42614 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755090Ab2BOLt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 06:49:29 -0500
Content-Disposition: inline
In-Reply-To: <4F3B16E4.5020507@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 15, 2012 at 10:22:28AM +0800, Li Zefan wrote:
> Neil Horman wrote:
> > About 2 weeks ago, Li Zefan posted a series of cleanups and fixes for cls_cgroup
> > and netprio_cgroup.  It was requested that the cleanups and fixes be separated
> > into two different series and reposted.  Its been about 2 weeks, and after
> > pinging the author a few times and getting no response, I've decided to repost
> > the fixes for netprio myself, as they're important and I don't want them to be
> > forgotten or otherwise fall through the cracks.
> > 
> 
> Thanks for the reposting.
> 
> I was off office for a few days for some reason, and just came back to work.
> 
No worries, thank you for checking back.
Neil
