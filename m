From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] tipc: move netlink policies to netlink.c
Date: Mon, 07 Mar 2016 14:56:55 -0500 (EST)
Message-ID: <20160307.145655.1846908007653575468.davem@davemloft.net>
References: <1457107482-15425-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753464AbcCGT46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 14:56:58 -0500
In-Reply-To: <1457107482-15425-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Fri, 4 Mar 2016 17:04:42 +0100

> Make the c files less cluttered and enable netlink attributes to be
> shared between files.
> 
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> Acked-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>

Applied, thanks for cleaning this up.
