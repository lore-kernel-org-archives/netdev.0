From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: 3x59x-fix-pci-resource-management.patch
Date: Fri, 7 Aug 2009 10:19:28 +0200
Message-ID: <20090807081928.GA12932@skl-net.de>
References: <20090806154223.b9b9759e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from systemlinux.org ([83.151.29.59]:60366 "EHLO m18s25.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756622AbZHGIU0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2009 04:20:26 -0400
Content-Disposition: inline
In-Reply-To: <20090806154223.b9b9759e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 06, 2009 at 03:42:23PM -0700, Andrew Morton wrote:
> 
> Guys, I seem to have been sitting on the below patch for, err, three years.
> 
> I generally do this because there's some issue which needs to be
> addressed, but the patch didn't address it right.
> 
> Can we please have a revisit and work out what we should do with this?
> 

I don't know the story from the beginning. Are there any issues with
this patch aside the compile error that was caused if CONFIG_PCI is not
enabled? The compile error should be fixed and the rest looks ok on the
first view.

