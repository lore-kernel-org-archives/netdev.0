From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] cxgb4: Add a check for flashing FW using ethtool
Date: Tue, 09 Dec 2014 13:21:43 -0500 (EST)
Message-ID: <20141209.132143.1694817049882562482.davem@davemloft.net>
References: <1417587590-26248-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079AbaLISVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:21:46 -0500
In-Reply-To: <1417587590-26248-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed,  3 Dec 2014 11:49:50 +0530

> Don't let T4 firmware flash on a T5 adapter and vice-versa
> using ethtool
> 
> Based on original work by Casey Leedom <leedom@chelsio.com>
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> 
> ---
> V2:
>  Use bool for return value based on review comment by Sergei Shtylyov

Applied, thanks.
