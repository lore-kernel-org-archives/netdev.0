From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: Add additional registers for
 dwmac1000_dma ethtool
Date: Thu, 29 Jun 2017 12:50:09 -0400 (EDT)
Message-ID: <20170629.125009.776539461615619113.davem@davemloft.net>
References: <1498601787-17390-1-git-send-email-thor.thayer@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: thor.thayer@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42636 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751333AbdF2QuM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 12:50:12 -0400
In-Reply-To: <1498601787-17390-1-git-send-email-thor.thayer@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: thor.thayer@linux.intel.com
Date: Tue, 27 Jun 2017 17:16:27 -0500

> From: Thor Thayer <thor.thayer@linux.intel.com>
> 
> Version 3.70a of the Designware has additional DMA registers so
> add those to the ethtool DMA Register dump.
> Offset 9  - Receive Interrupt Watchdog Timer Register
> Offset 10 - AXI Bus Mode Register
> Offset 11 - AHB or AXI Status Register
> Offset 22 - HW Feature Register
> 
> Signed-off-by: Thor Thayer <thor.thayer@linux.intel.com>

Applied to net-next, thanks.
