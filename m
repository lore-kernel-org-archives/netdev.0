From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] Misc. fixes for cxgb4
Date: Thu, 13 Mar 2014 14:36:41 -0400 (EDT)
Message-ID: <20140313.143641.1743287248900390939.davem@davemloft.net>
References: <1394724050-9291-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754466AbaCMSgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 14:36:46 -0400
In-Reply-To: <1394724050-9291-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Thu, 13 Mar 2014 20:50:45 +0530

> This patch series provides miscelleneous fixes for Chelsio T4/T5 adapters
> cxgb4 driver related to SGE and MTU.
> 
> Also fixes regression in LSO calcuation path.
> ("cxgb4: Calculate len properly for LSO path")
> 
> The patches series is created against David Miller's 'net-next' tree.
> And includes patches on cxgb4 driver.
> 
> We would like to request this patch series to get merged via David Miller's
> 'net-next' tree.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.

Series applied, thanks.
