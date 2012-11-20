From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] netfilter: Remove the spurious \ in __ip_vs_lblc_init
Date: Tue, 20 Nov 2012 09:12:32 +0900
Message-ID: <20121120001232.GF13829@verge.net.au>
References: <87zk2d7gwp.fsf@xmission.com>
 <20121120000649.GC13829@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:50221 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753393Ab2KTAMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 19:12:36 -0500
Content-Disposition: inline
In-Reply-To: <20121120000649.GC13829@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 20, 2012 at 09:06:49AM +0900, Simon Horman wrote:
> On Mon, Nov 19, 2012 at 07:26:30AM -0800, Eric W. Biederman wrote:
> > 
> > In (464dc801c76a net: Don't export sysctls to unprivileged users)
> > I typoed and introduced a spurious backslash.  Delete it.
> > 
> > Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> Pablo, can you take this directly through your tree?

Scratch that, I see that David has already applied this change.
