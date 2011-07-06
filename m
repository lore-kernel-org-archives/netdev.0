From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 2/2] dcbnl: Add CEE notification
Date: Tue, 05 Jul 2011 23:43:32 -0700 (PDT)
Message-ID: <20110705.234332.909934384241580169.davem@davemloft.net>
References: <1309882585.22577.9.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: shmulikr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36952 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836Ab1GFGnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 02:43:35 -0400
In-Reply-To: <1309882585.22577.9.camel@lb-tlvb-shmulik.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Shmulik Ravid" <shmulikr@broadcom.com>
Date: Tue, 5 Jul 2011 19:16:25 +0300

> This patch add an unsolicited notification of the DCBX negotiated
> parameters for the CEE flavor of the DCBX protocol. The notification
> message is identical to the aggregated CEE get operation and holds all
> the pertinent local and peer information. The notification routine is
> exported so it can be invoked by drivers supporting an embedded DCBX
> stack.
> 
> Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>

Applied.
