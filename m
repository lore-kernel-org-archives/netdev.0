From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: add tlb_dynamic_lb netlink support
Date: Fri, 31 Jul 2015 15:40:14 -0700 (PDT)
Message-ID: <20150731.154014.112181013969107522.davem@davemloft.net>
References: <1438354183-1907-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbbGaWkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 18:40:16 -0400
In-Reply-To: <1438354183-1907-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Fri, 31 Jul 2015 16:49:43 +0200

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> tlb_dynamic_lb could be set only via sysfs, this patch allows it to be
> set via netlink.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> As usual if accepted I'll post the corresponding iproute2 patch that adds
> support for setting tlb_dynamic_lb.

Applied, thanks for filling in all of these holes in the netlink interface.
