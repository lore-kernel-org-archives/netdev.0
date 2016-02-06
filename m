From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 2/2] tipc: fix link priority propagation
Date: Sat, 06 Feb 2016 02:46:04 -0500 (EST)
Message-ID: <20160206.024604.218916025834000988.davem@davemloft.net>
References: <1454311197-10948-1-git-send-email-richard.alpe@ericsson.com>
	<1454311197-10948-2-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47606 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524AbcBFHqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 02:46:07 -0500
In-Reply-To: <1454311197-10948-2-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Mon, 1 Feb 2016 08:19:57 +0100

> Currently link priority changes isn't handled for active links. In
> this patch we resolve this by changing our priority if the peer passes
> a valid priority in a state message.
> 
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>

Applied.
