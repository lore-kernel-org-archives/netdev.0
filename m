From: David Miller <davem@davemloft.net>
Subject: Re: pull request: sfc-next-2.6 2011-04-03
Date: Sun, 03 Apr 2011 17:50:07 -0700 (PDT)
Message-ID: <20110403.175007.214221616.davem@davemloft.net>
References: <1301859889.2935.23.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48709
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751042Ab1DDAuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 20:50:44 -0400
In-Reply-To: <1301859889.2935.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sun, 03 Apr 2011 20:44:49 +0100

> The following changes since commit 9b12c75bf4d58dd85c987ee7b6a4356fdc7c1222:
>   David S. Miller (1):
>         net: Order ports in same order as addresses in flow objects.
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next-2.6.git master
> 
> 1. Implement of generic features interface in sfc.
> 2. Update ethtool_ops documentation.
> 3. Reimplement ETHTOOL_PHYS_ID as dicussed, dropping the RTNL lock.
> 
> Please allow some time for others to review before pulling.

Ok, it seems there has been some feedback and you'll need to respin
these changes.
