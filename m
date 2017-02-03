From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: add separate warning for PTP not being
 supported by HW
Date: Thu, 02 Feb 2017 22:01:38 -0500 (EST)
Message-ID: <20170202.220138.452126742272467066.davem@davemloft.net>
References: <0983485b-418d-5c9b-e94b-8f4edc9f13cf@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-amlogic@lists.infradead.org
To: hkallweit1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38390 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751839AbdBCDBk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 22:01:40 -0500
In-Reply-To: <0983485b-418d-5c9b-e94b-8f4edc9f13cf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiner Kallweit <hkallweit1@gmail.com>
Date: Wed, 1 Feb 2017 22:02:02 +0100

> Chips like Amlogic S905GXBB are supported by this driver but don't
> have support for PTP. Add a separate warning for missing HW support
> to differentiate it from other actual failures.
> 
> Signed-off-by: Heiner Kallweit <hkallweit1@gmail.com>

Applied to net-netxt.
