From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ethernet: stmmac: make DWMAC_STM32 depend on it's
 associated SoC
Date: Mon, 21 Nov 2016 11:34:45 -0500 (EST)
Message-ID: <20161121.113445.2010069916205748974.davem@davemloft.net>
References: <20161120172238.7919-1-pbrobinson@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        mcoquelin.stm32@gmail.com, netdev@vger.kernel.org
To: pbrobinson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53208 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754604AbcKUQgG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 11:36:06 -0500
In-Reply-To: <20161120172238.7919-1-pbrobinson@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Robinson <pbrobinson@gmail.com>
Date: Sun, 20 Nov 2016 17:22:38 +0000

> There's not much point, except compile test, enabling the stmmac
> platform drivers unless the STM32 SoC is enabled. It's not
> useful without it.
> 
> Signed-off-by: Peter Robinson <pbrobinson@gmail.com>

Applied.
