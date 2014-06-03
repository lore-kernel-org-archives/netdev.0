From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: Fixes for new ethtool RSS commands
Date: Mon, 02 Jun 2014 17:13:14 -0700 (PDT)
Message-ID: <20140602.171314.565532478564496551.davem@davemloft.net>
References: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37975 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753071AbaFCANP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 20:13:15 -0400
In-Reply-To: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 02 Jun 2014 01:57:39 +0100

> The following changes since commit eb02a272c97b6e25d8e5fcf1ea93923e6f155595:
> 
>   driver/net/ethernet/ec_bhf.c: fix sparse warnings (2014-05-14 16:09:33 -0400)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/net-next.git ethtool-rssh-fixes
> 
> for you to fetch changes up to dfe805c14a2018c5a58cfa3921f1897032740501:
> 
>   ethtool: Check that reserved fields of struct ethtool_rxfh are 0 (2014-05-19 01:30:30 +0100)
> 
> This addresses several problems I previously identified with the new
> ETHTOOL_{G,S}RSSH commands:

Pulled into net-next, thanks Ben.
