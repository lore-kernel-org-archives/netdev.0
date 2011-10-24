From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/5] macvtap fixes.
Date: Mon, 24 Oct 2011 08:31:06 +0200
Message-ID: <20111024063105.GA25117@redhat.com>
References: <m1wrbzu4ec.fsf@fess.ebiederm.org>
 <20111021.025607.2193225431127507358.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, arnd@arnd.de,
	jasowang@redhat.com, ian.campbell@citrix.com, mashirley@us.ibm.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41387 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753224Ab1JXGai (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Oct 2011 02:30:38 -0400
Content-Disposition: inline
In-Reply-To: <20111021.025607.2193225431127507358.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 21, 2011 at 02:56:07AM -0400, David Miller wrote:
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Thu, 20 Oct 2011 07:24:59 -0700
> 
> > 
> > This series of patches fixes a series of minor bugs in the macvtap code.
> > 
> > The fixes to handle failures in newlink and the change in how we handle
> > minor device number allocations are particularly significant.
> 
> Applied to net-next, thanks.

The 'Don't leak unreceived packets' patch probably makes sense in 'net'.

-- 
MST
