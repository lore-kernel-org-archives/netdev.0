From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] tipc: honor msg2addr return value
Date: Wed, 29 Jun 2016 05:18:12 -0400 (EDT)
Message-ID: <20160629.051812.1224762989788295100.davem@davemloft.net>
References: <1467027247-25469-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39423 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752686AbcF2JSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 05:18:39 -0400
In-Reply-To: <1467027247-25469-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Mon, 27 Jun 2016 13:34:06 +0200

> The UDP msg2addr function tipc_udp_msg2addr() can return -EINVAL which
> prior to this patch was unhanded in the caller.
> 
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Acked-by: Jon Maloy <jon.maloy@ericsson.com>
> Acked-by: Ying Xue <ying.xue@windriver.com>

Applied.
