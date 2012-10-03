From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: Dynamically allocate memory in t4_memory_rw()
 and get_vpd_params()
Date: Wed, 03 Oct 2012 16:35:59 -0400 (EDT)
Message-ID: <20121003.163559.885534069422787891.davem@davemloft.net>
References: <1349270552-6678-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, dm@chelsio.com,
	leedom@chelsio.com, felix@chelsio.com, jay@chelsio.com
To: vipul@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753734Ab2JCUgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 16:36:07 -0400
In-Reply-To: <1349270552-6678-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul@chelsio.com>
Date: Wed,  3 Oct 2012 18:52:32 +0530

> This patch changes memory allocation to reduce stack footprint
> 
> Signed-off-by: Jay Hernandez <jay@chelsio.com>
> Signed-off-by: Vipul Pandya <vipul@chelsio.com>

Applied.
