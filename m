From: Kees Cook <kees.cook@canonical.com>
Subject: Re: shutdown(2) does not fully shut down socket any more
Date: Fri, 8 Apr 2011 15:46:24 -0700
Message-ID: <20110408224624.GZ4050@outflux.net>
References: <20110408221046.GW4050@outflux.net>
 <20110408.152427.193714809.davem@davemloft.net>
 <20110408223004.GY4050@outflux.net>
 <20110408.153130.226769035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.outflux.net ([198.145.64.163]:33966 "EHLO smtp.outflux.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752843Ab1DHWq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 18:46:26 -0400
Content-Disposition: inline
In-Reply-To: <20110408.153130.226769035.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 08, 2011 at 03:31:30PM -0700, David Miller wrote:
> From: Kees Cook <kees.cook@canonical.com>
> Date: Fri, 8 Apr 2011 15:30:04 -0700
> 
> > Ah! Thanks, I didn't noticed that; I saw no activity on the bugzilla entry,
> > so I thought it hadn't been seen yet.
> 
> We bascially do not use kernel.org bugzilla for bug tracking, all
> work and discussions occur only here on the netdev list.
> 
> So what Stephen Hemminger, Andrew Morton, and others do is simply
> forward the bug reports here to the list so we can work on them.

Makes sense, yeah. It'd be cool if the forwarder added a note to the bug
saying "this has been forwarded [here]". Then the reporter would know where
to go look for status updates.

But, regardless, it's being looked at. Thanks!

-Kees

-- 
Kees Cook
Ubuntu Security Team
