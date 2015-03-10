From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: fix coccinelle warnings
Date: Tue, 10 Mar 2015 13:42:14 -0400 (EDT)
Message-ID: <20150310.134214.1256908525470846949.davem@davemloft.net>
References: <1425989692-22391-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57574 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbbCJRmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 13:42:17 -0400
In-Reply-To: <1425989692-22391-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue, 10 Mar 2015 17:44:52 +0530

> Commit 16e47624e76b43db ("cxgb4: Add new scheme to update T4/T5 firmware")
> introduced below coccinelle warning.
> 
>>> drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:994:2-8: Replace memcpy with
>    struct assignment
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
