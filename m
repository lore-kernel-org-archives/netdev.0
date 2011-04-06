From: David Miller <davem@davemloft.net>
Subject: Re: pull request: sfc-next-2.6 2011-04-05
Date: Wed, 06 Apr 2011 12:29:29 -0700 (PDT)
Message-ID: <20110406.122929.39170001.davem@davemloft.net>
References: <1302026446.2932.56.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	shemminger@vyatta.com, mirq-linux@rere.qmqm.pl
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32942
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753888Ab1DFTaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 15:30:06 -0400
In-Reply-To: <1302026446.2932.56.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 05 Apr 2011 19:00:46 +0100

> The following changes since commit 9b12c75bf4d58dd85c987ee7b6a4356fdc7c1222:
> 
>   net: Order ports in same order as addresses in flow objects. (2011-03-31 18:03:35 -0700)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next-2.6.git for-davem
> 
> 1. Implement generic features interface in sfc.
> 2. Update ethtool_ops documentation.
> 3. Reimplement ETHTOOL_PHYS_ID as dicussed, dropping the RTNL lock.
 ...

Pulled, thanks a lot Ben!
