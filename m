From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/7] Update Kconfig and some fixes for cxgb4
Date: Tue, 08 Dec 2015 22:43:32 -0500 (EST)
Message-ID: <20151208.224332.1300792372193306796.davem@davemloft.net>
References: <1449549557-16023-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbbLIDne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 22:43:34 -0500
In-Reply-To: <1449549557-16023-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue,  8 Dec 2015 10:09:10 +0530

> This series update Kconfig to add description for Chelsio's next
> generation T6 family of adapters, also fixes ethtool stats alignment
> and prevents simultaneous execution of service_ofldq thread, deals with
> queue wrap around and adds some fl counters for debugging purpose and
> device ID for new T5 adapters.
> 
> This patch series has been created against net-next tree and includes
> patches on cxgb4 driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.
> 
> Thanks
> 
> V2: Declare 'service_ofldq_running' as bool in Patch 4/7 ("cxgb4: prevent
>     simultaneous execution of service_ofldq()") based on review comment
>     by David Miller

Series applied, thanks.
