From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10] ftgmac: Rework batch 2 - RX path
Date: Thu, 06 Apr 2017 15:40:06 -0700 (PDT)
Message-ID: <20170406.154006.718076544200026820.davem@davemloft.net>
References: <20170406010252.29208-1-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40916 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752331AbdDFWkO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 18:40:14 -0400
In-Reply-To: <20170406010252.29208-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu,  6 Apr 2017 11:02:42 +1000

> This is the second batch of updates to the ftgmac100 driver.
> 
> This one tackles the RX path of the driver, simplifying
> it greatly to match common practice while significantly
> increasing the performance.
> 
> (The bulk of the performance gains of my series will be
> provided by the TX path improvements, notably fragmented
> sends, these will be in the next batch).

Looks good, series applied, thanks.
