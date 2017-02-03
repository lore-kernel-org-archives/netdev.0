From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: don't set tx delay in RGMII_ID and
 RGMII_TXID mode
Date: Thu, 02 Feb 2017 22:00:09 -0500 (EST)
Message-ID: <20170202.220009.1028272302182207088.davem@davemloft.net>
References: <ed022e67-2494-209e-9e51-b7a57c219d02@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: martin.blumenstingl@googlemail.com, netdev@vger.kernel.org,
        linux-amlogic@lists.infradead.org
To: hkallweit1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38232 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752122AbdBCDAK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 22:00:10 -0500
In-Reply-To: <ed022e67-2494-209e-9e51-b7a57c219d02@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiner Kallweit <hkallweit1@gmail.com>
Date: Wed, 1 Feb 2017 20:19:25 +0100

> As documented in Documentation/devicetree/bindings/net/ethernet.txt,
> in RGMII_ID and RGMII_TXID mode the MAC should not add a tx delay.
> 
> Signed-off-by: Heiner Kallweit <hkallweit1@gmail.com>

Applied to net-next, thank you.
