From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] cdc_ether/zaurus: Move Harmony 900 from cdc_ether
 to zaurus
Date: Tue, 21 Feb 2012 15:29:55 -0500 (EST)
Message-ID: <20120221.152955.249474042996682217.davem@davemloft.net>
References: <alpine.LRH.2.02.1202202114180.382@bear.techie.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: talbert@techie.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148Ab2BUUaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 15:30:01 -0500
In-Reply-To: <alpine.LRH.2.02.1202202114180.382@bear.techie.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Talbert <talbert@techie.net>
Date: Mon, 20 Feb 2012 21:29:29 -0500 (EST)

> In the current kernel implementation, the Logitech Harmony 900 remote
> control is matched to the cdc_ether driver through the generic
> USB_CDC_SUBCLASS_MDLM entry.  However, this device appears to be of
> the pseudo-MDLM (Belcarra) type, rather than the standard one.  This
> patch blacklists the Harmony 900 from the cdc_ether driver and
> whitelists it for the pseudo-MDLM driver in zaurus.
> 
> Signed-off-by: Scott Talbert <talbert@techie.net>

This patch doesn't apply because your email client corrupted the
patch.

Please freshly resubmit a fixed version of this patch, but only
after you have successfully emailed this patch to yourself and
are successfully able to apply the patch you receive in that
email.

Thanks.
