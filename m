From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] cxgb4/cxgb4vf: Cleanup and minor fixes
Date: Wed, 02 Mar 2016 14:46:50 -0500 (EST)
Message-ID: <20160302.144650.789980250487814158.davem@davemloft.net>
References: <1456832976-12840-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, leedom@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbcCBTqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 14:46:52 -0500
In-Reply-To: <1456832976-12840-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue,  1 Mar 2016 17:19:31 +0530

> This series sets FBMIN to 64 bytes for Chelsio's T6 series of adapters,
> check to replenish fl is revised, some code cleanup in cxgb4vf sge
> initialization code and removes dead code. 
> 
> This patch series has been created against net-next tree and includes
> patches on cxgb4 and cxgb4vf driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.

Series applied, thanks.
