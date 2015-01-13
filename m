From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: remove redundant timer defined in
 tipc_sock struct
Date: Tue, 13 Jan 2015 16:46:41 -0500 (EST)
Message-ID: <20150113.164641.1812429919881850062.davem@davemloft.net>
References: <1421140068-3614-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, ericalp@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbbAMVqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:46:45 -0500
In-Reply-To: <1421140068-3614-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Tue, 13 Jan 2015 17:07:48 +0800

> Remove the redundant timer defined in tipc_sock structure, instead we
> can directly reuse the sk_timer defined in sock structure.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Acked-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thank you.
