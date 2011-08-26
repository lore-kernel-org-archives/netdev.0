From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Add new PHY BCM54616
Date: Fri, 26 Aug 2011 12:51:26 -0400 (EDT)
Message-ID: <20110826.125126.115597973685663614.davem@davemloft.net>
References: <1314117204.28819.13.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: yanivr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755343Ab1HZQv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:51:29 -0400
In-Reply-To: <1314117204.28819.13.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yaniv Rosner" <yanivr@broadcom.com>
Date: Tue, 23 Aug 2011 19:33:24 +0300

> The BCM54616 PHY is very similar to the 54618SE, only without EEE support, which will not be activated due to querying the actual PHY type.
> This check is already done by reading a dedicated PHY register.
> 
> Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
