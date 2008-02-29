From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/08 net-2.6.26] [TIPC]: Minor cleanup of message
 header code
Date: Fri, 29 Feb 2008 11:49:50 -0800 (PST)
Message-ID: <20080229.114950.159695863.davem@davemloft.net>
References: <AF1602CB2550CE4381C0C75118A7856B0252DE23@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39431
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758449AbYB2Ttu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 14:49:50 -0500
In-Reply-To: <AF1602CB2550CE4381C0C75118A7856B0252DE23@ala-mail02.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Stephens, Allan" <allan.stephens@windriver.com>
Date: Fri, 29 Feb 2008 10:40:49 -0800

> @@ -2832,15 +2832,15 @@ static void link_set_supervision_props(struct
> link *l_ptr, u32 tolerance)
>  void tipc_link_set_queue_limits(struct link *l_ptr, u32 window)
>  {
>  	/* Data messages from this node, inclusive FIRST_FRAGM */

Your email client has corrupted the patch by breaking up long
lines.

I'm ignoring this entire patch set, sorry.
