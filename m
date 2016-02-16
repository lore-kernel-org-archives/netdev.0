From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1] tipc: refactor node xmit and fix memory
 leaks
Date: Tue, 16 Feb 2016 16:01:47 -0500 (EST)
Message-ID: <20160216.160147.176511989643994015.davem@davemloft.net>
References: <1455183795-15303-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbcBPVBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 16:01:49 -0500
In-Reply-To: <1455183795-15303-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Thu, 11 Feb 2016 10:43:15 +0100

> Refactor tipc_node_xmit() to fail fast and fail early. Fix several
> potential memory leaks in unexpected error paths.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>

Applied, thanks.
