From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 0/4] net: fec: Code cleanup
Date: Fri, 26 Sep 2014 16:06:02 -0400 (EDT)
Message-ID: <20140926.160602.1429816882470314568.davem@davemloft.net>
References: <1411458058-18934-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b20596@freescale.com
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754243AbaIZUGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 16:06:04 -0400
In-Reply-To: <1411458058-18934-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Tue, 23 Sep 2014 15:40:54 +0800

> This patches does several things:
>   - Fixing multiqueue issue.
>   - Removing the unnecessary errata workaround.
>   - Aligning the data buffer dma map/unmap size.
>   - Freeing resource after probe failed.

Series applied to net-next, thanks.

Please always explicitly state what tree you expect your patches to be
applied to in the future.
