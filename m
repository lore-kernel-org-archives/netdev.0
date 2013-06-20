From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] bnx2x: add support for low latency rx
Date: Wed, 19 Jun 2013 18:32:35 -0700 (PDT)
Message-ID: <20130619.183235.562587242641234572.davem@davemloft.net>
References: <1371594965-12546-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935297Ab3FTBcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 21:32:36 -0400
In-Reply-To: <1371594965-12546-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Wed, 19 Jun 2013 01:36:03 +0300

> This series adds to bnx2x driver capabilities for low latency rx.
> It bases on ixgbe driver code and tested with TCP_RR/UDP_RR.
> The results show about 50% boost in both scenarious. With second patch
> we have additional 5%.
> 
> Please, consider applying it to net-next.

Applied, thanks.
