From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] altera tse: add support for lixed-links.
Date: Tue, 21 Apr 2015 17:37:27 -0400 (EDT)
Message-ID: <20150421.173727.2175461834810068643.davem@davemloft.net>
References: <1429633945-30463-1-git-send-email-ennoerlangen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridger@opensource.altera.com, netdev@vger.kernel.org,
	nios2-dev@lists.rocketboards.org, ennoerlangen@gmail.com
To: ennoerlangen@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55863 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933282AbbDUVh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 17:37:28 -0400
In-Reply-To: <1429633945-30463-1-git-send-email-ennoerlangen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Oetken <ennoerlangen@googlemail.com>
Date: Tue, 21 Apr 2015 18:32:25 +0200

Subject typo "lixed --> fixed"

> +			/* In the case of a fixed PHY, the DT node associated
> +			* to the PHY is the Ethernet MAC DT node.
> +			*/

Not indented properly, the second and third line of this comment need
one extra space before the first "*".
