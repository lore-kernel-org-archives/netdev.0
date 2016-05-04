From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] cxgb4: mbox enhancements for cxgb4
Date: Wed, 04 May 2016 13:59:47 -0400 (EDT)
Message-ID: <20160504.135947.913789555328619518.davem@davemloft.net>
References: <1462282082-6894-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com,
	swise@opengridcomputing.com, nirranjan@chelsio.com,
	santosh@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41007 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbcEDR7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 13:59:49 -0400
In-Reply-To: <1462282082-6894-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue,  3 May 2016 18:58:00 +0530

> This patch series checks for firmware errors when we are waiting for
> mbox response in a loop and breaks out. When negative timeout is passed
> to mailbox code, don't sleep. Negative timeout is passed only from
> interrupt context.
> 
> This patch series has been created against net-next tree and includes
> patches on cxgb4 driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.

Series applied, thanks.
