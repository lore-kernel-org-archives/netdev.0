From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: Initialize data structures before using.
Date: Wed, 07 Nov 2012 15:43:36 -0500 (EST)
Message-ID: <20121107.154336.1810736680914262607.davem@davemloft.net>
References: <1352209029-4291-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, dm@chelsio.com,
	jay@chelsio.com
To: vipul@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40999 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802Ab2KGUnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 15:43:37 -0500
In-Reply-To: <1352209029-4291-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul@chelsio.com>
Date: Tue,  6 Nov 2012 19:07:09 +0530

> We should not assume reserve fields to be don't cares as fields may change.
> Clearing data structures before using.
> 
> Signed-off-by: Jay Hernandez <jay@chelsio.com>
> Signed-off-by: Vipul Pandya <vipul@chelsio.com>

Applied, thanks.
