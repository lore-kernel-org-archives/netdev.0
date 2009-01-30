From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 00/20] sfc: Fixes and new PHY support for 2.6.29
Date: Fri, 30 Jan 2009 01:05:43 +0000
Message-ID: <20090130010542.GB15266@solarflare.com>
References: <1233256358.3656.9.camel@achroite> <20090129.152608.218445220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:41062 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754754AbZA3BFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 20:05:50 -0500
Content-Disposition: inline
In-Reply-To: <20090129.152608.218445220.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> 
> I'm not taking a blob of 20 patches to a driver outside of the merge
> window, no freakin' way.

Sorry about that; I should have separated them out more clearly.

1. Patches 3, 6-13 and 20 fix bugs introduced or exposed by the
   changes already accepted for .29.  I regret that I couldn't send
   these earlier but I simply didn't have near-production hardware or
   firmware to test against until the last couple of weeks.
2. Patches 16 and 19 add new hardware support without affecting the
   behaviour on old hardware.
3. Patches 14, 15, 17 and 18 are fairly trivial fixes supporting those.
4. Patches 2 and 4 fix longstanding bugs.
5. Patches 1 and 5 add features.

Please take at least the patches in group 1.  I will re-send if you
wish.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
