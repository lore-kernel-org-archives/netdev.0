From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] cxgb4: Misc. fixes for sge
Date: Tue, 14 Apr 2015 15:09:11 -0400 (EDT)
Message-ID: <20150414.150911.1202392442779426441.davem@davemloft.net>
References: <1429043554-8744-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbbDNTJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 15:09:14 -0400
In-Reply-To: <1429043554-8744-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 15 Apr 2015 02:02:29 +0530

> Increases value of MAX_IMM_TX_PKT_LEN to improve latency, fill freelist
> starving threshold based on adapter type, add comments for tx flits and sge
> length code and don't call t4_slow_intr_handler when we are not master PF.
> 
> This patch series has been created against net-next tree and includes patches on
> cxgb4 driver
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.

Series applied, thanks.
