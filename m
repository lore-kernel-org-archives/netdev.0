From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: Remove the spurious \ in __ip_vs_lblc_init
Date: Mon, 19 Nov 2012 19:12:43 -0500 (EST)
Message-ID: <20121119.191243.774906121861540201.davem@davemloft.net>
References: <87zk2d7gwp.fsf@xmission.com>
	<20121120000649.GC13829@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, pablo@netfilter.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34831 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753695Ab2KTAMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 19:12:45 -0500
In-Reply-To: <20121120000649.GC13829@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Tue, 20 Nov 2012 09:06:49 +0900

> On Mon, Nov 19, 2012 at 07:26:30AM -0800, Eric W. Biederman wrote:
>> 
>> In (464dc801c76a net: Don't export sysctls to unprivileged users)
>> I typoed and introduced a spurious backslash.  Delete it.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> Pablo, can you take this directly through your tree?

I already applied this to net-next yesterday.
