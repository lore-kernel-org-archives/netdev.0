From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ksz884x: fix mtu for VLAN
Date: Wed, 11 Jan 2012 12:47:13 -0800 (PST)
Message-ID: <20120111.124713.534230702535605364.davem@davemloft.net>
References: <1326313306.57525.YahooMailNeo@web39305.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rdkehn@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933248Ab2AKUrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 15:47:16 -0500
In-Reply-To: <1326313306.57525.YahooMailNeo@web39305.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Doug Kehn <rdkehn@yahoo.com>
Date: Wed, 11 Jan 2012 12:21:46 -0800 (PST)

> The Ethernet header does not account for the addition of a VLAN header.
> Full size Ethernet frames containing VLAN header are not processed
> because the frame is larger than the resulting hw mtu.
> 
> Signed-off-by: Doug Kehn <rdkehn@yahoo.com>

Your email client corrupted your patch making it unusable to us.

Send the patch to yourself, and try to apply the patch you receive.
Only resubmit your patch again here once you are able to do that
successfully.
