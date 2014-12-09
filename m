From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] cxgb4/cxgb4vf: T5 BAR2 and ethtool
 related fixes
Date: Tue, 09 Dec 2014 13:32:24 -0500 (EST)
Message-ID: <20141209.133224.1709861546287397344.davem@davemloft.net>
References: <1417615374-12961-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37301 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbaLISc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:32:28 -0500
In-Reply-To: <1417615374-12961-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed,  3 Dec 2014 19:32:50 +0530

> This series adds new interface to calculate BAR2 SGE queue register address for
> cxgb4 and cxgb4vf driver and some more sge related fixes for T5. Also adds a
> patch which updates the FW version displayed by ethtool after firmware flash. 
> 
> The patches series is created against 'net-next' tree.
> And includes patches on cxgb4 and cxgb4vf driver.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.

Applied, thanks.
