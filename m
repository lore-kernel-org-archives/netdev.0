From: David Miller <davem@davemloft.net>
Subject: Re: pull request: sfc 2012-03-09
Date: Fri, 09 Mar 2012 21:56:17 -0500 (EST)
Message-ID: <20120309.215617.1507119324015980345.davem@davemloft.net>
References: <1331340409.2537.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52555 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758902Ab2CJC4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 21:56:20 -0500
In-Reply-To: <1331340409.2537.10.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 10 Mar 2012 00:46:49 +0000

> The following changes since commit ffcb97388b1d41b1db063eb041cb9af408662127:
> 
>   Merge branch 'master' of git://gitorious.org/linux-can/linux-can-next (2012-03-04 21:59:39 -0500)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem
> 
> (commit 460eeaa03c5c0af32a388337a6e1f0f1acd043ce)
> 
> 1. Fix a bug in SR-IOV support that I introduced while cleaning it up
> prior to upstreaming.
> 2. Show the part number for all boards at probe time, not just the ones
> we have specific code for.
> 3. Improve self-test reliability, and test interrupts & events
> immediately after bringing an interface up.
> 4. Improve adaptive IRQ moderation.
> 5. Various cleanup.

Pulled, thanks Ben.
