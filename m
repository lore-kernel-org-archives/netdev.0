From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 3/4] Make net watchdog timers 1 sec jiffy aligned
Date: Wed, 30 May 2007 17:36:12 -0500
Message-ID: <20070530223612.GR11115@waste.org>
References: <465DC598.5060407@trash.net> <20070530.125551.41636333.davem@davemloft.net> <20070530221039.GJ11166@waste.org> <20070530.152939.21591222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, shemminger@linux-foundation.org,
	akpm@linux-foundation.org, venkatesh.pallipadi@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:42474 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753738AbXE3Wgi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 18:36:38 -0400
Content-Disposition: inline
In-Reply-To: <20070530.152939.21591222.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 30, 2007 at 03:29:39PM -0700, David Miller wrote:
> From: Matt Mackall <mpm@selenic.com>
> Date: Wed, 30 May 2007 17:10:39 -0500
> 
> > Are you agreeing that "it seems wasteful to add per-packet overhead"?
> > This patch is not doing that.
> 
> Yes, and I know that :-)

Is there a real reason for watchdog_timeo to be all over the map?

-- 
Mathematics is the supreme nostalgia of our time.
