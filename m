From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4vf: Fix extraction of cpl_rx_pkt from
 the response queue descriptor
Date: Fri, 08 Feb 2013 17:57:55 -0500 (EST)
Message-ID: <20130208.175755.2107905071249762971.davem@davemloft.net>
References: <1360327791-21704-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, dm@chelsio.com,
	leedom@chelsio.com, abhishek@chelsio.com, jay@chelsio.com
To: vipul@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38116 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947094Ab3BHW55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 17:57:57 -0500
In-Reply-To: <1360327791-21704-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul@chelsio.com>
Date: Fri,  8 Feb 2013 18:19:51 +0530

> This was preventing GRO and RxCheckSum offload to happen.
> 
> Signed-off-by: Jay Hernandez <jay@chelsio.com>
> Signed-off-by: Vipul Pandya <vipul@chelsio.com>

Applied.
