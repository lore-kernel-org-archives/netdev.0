From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] tipc: add peer removal functionality
Date: Tue, 12 Jan 2016 15:31:44 -0500 (EST)
Message-ID: <20160112.153144.290968220348314280.davem@davemloft.net>
References: <1452607696-24216-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667AbcALUbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 15:31:46 -0500
In-Reply-To: <1452607696-24216-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Tue, 12 Jan 2016 15:08:16 +0100

> Add TIPC_NL_PEER_REMOVE netlink command. This command can remove
> an offline peer node from the internal data structures.
> 
> This will be supported by the tipc user space tool in iproute2.
> 
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> Acked-by: Ying Xue <ying.xue@windriver.com>

Please see:

	http://marc.info/?l=linux-netdev&m=145248145925834&w=2
