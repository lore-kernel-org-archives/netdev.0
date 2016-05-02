From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-next 0/7] net: Cleanup IPv6 ip tunnels
Date: Mon, 02 May 2016 19:23:47 -0400 (EDT)
Message-ID: <20160502.192347.907887703670993024.davem@davemloft.net>
References: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37656 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755240AbcEBXXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 19:23:50 -0400
In-Reply-To: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Fri, 29 Apr 2016 17:12:14 -0700

> The IPv6 tunnel code is very different from IPv4 code. There is a lot
> of redundancy with the IPv4 code, particularly in the GRE tunneling.
> 
> This patch set cleans up the tunnel code to make the IPv6 code look
> more like the IPv4 code and use common functions between the two
> stacks where possible.

Series applied, nice work Tom.
