From: David Miller <davem@davemloft.net>
Subject: Re: pull request: sfc-next 2012-05-09
Date: Wed, 09 May 2012 22:51:26 -0400 (EDT)
Message-ID: <20120509.225126.61909968298486745.davem@davemloft.net>
References: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45496 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668Ab2EJCvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 22:51:32 -0400
In-Reply-To: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 10 May 2012 03:26:39 +0100

> The following changes since commit 2e7d21c54adbab6d10481eddc685328f89bb6389:
> 
>   e1000e: Fix merge conflict (net->net-next) (2012-05-09 12:06:39 -0400)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem
> 
> (commit ba62b2a8608ca52234fc8bea27bfebbdc4f98c2e)
> 
> 1. A fix for recovery from some hardware failure modes, by Stuart Hodgson.
> 2. Reduction of RX jitter, by David Riddoch.
> 3. ethtool interface and implementation for reading plug-in modules, mostly by
>    Stuart Hodgson.
> 4. A minor fix to PCI device cleanup.

Pulled, thanks.
