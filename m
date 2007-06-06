From: Christoph Hellwig <hch@infradead.org>
Subject: Re: warnings in git-wireless
Date: Wed, 6 Jun 2007 08:20:16 +0100
Message-ID: <20070606072016.GA4805@infradead.org>
References: <20070605020614.3f06b2ab.akpm@linux-foundation.org> <20070605115701.GA5391@tuxdriver.com> <4665C393.2000507@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:46882 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbXFFHU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 03:20:26 -0400
Content-Disposition: inline
In-Reply-To: <4665C393.2000507@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 05, 2007 at 01:12:03PM -0700, James Ketrenos wrote:
> Yes, we certainly don't want a driver to be "near mainline" that does 
> things that the rest of the kernel and other drivers are doing.  We should 
> force them to stay out-of-tree until any and everything is resolved.  
> Heaven forbid that the code should be merged, contributed, and improved 
> upon as a community.
> 
> You'd think these guys were trying to enable folks with a driver so they 
> can use the hardware they bought or something.  Its almost laughable.  What 
> idiots.

Maybe you should make sure your companies publishes specs or useable drivers
earlier, and you should stop writing crap code instead of these hypocritical 
comments.  We're a big project and we need to be up to some standards before
we can put code in that we'll have to maintain then.

> 
> James
> -
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
---end quoted text---
