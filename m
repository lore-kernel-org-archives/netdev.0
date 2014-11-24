From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net_test_tools] route_bench: Fix bug in DST_ITERATE
 option
Date: Mon, 24 Nov 2014 16:09:32 -0500 (EST)
Message-ID: <20141124.160932.1535765335085310139.davem@davemloft.net>
References: <1416816819-17310-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53670 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbaKXVJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 16:09:34 -0500
In-Reply-To: <1416816819-17310-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <subramanian.vijay@gmail.com>
Date: Mon, 24 Nov 2014 00:13:39 -0800

> While setting option for dst_addr_stride, flags should be set for
> FLAG_DST_ITERATE not FLAG_SRC_ITERATE.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>

This does not apply to the 'net' tree.
