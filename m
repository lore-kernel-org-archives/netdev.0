From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ethernet: stmmac: make DWMAC_STM32 depend on it's
 associated SoC
Date: Sun, 06 Nov 2016 21:41:28 -0500 (EST)
Message-ID: <20161106.214128.668519501329683090.davem@davemloft.net>
References: <20161106200437.12312-1-pbrobinson@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcoquelin.stm32@gmail.com, alexandre.torgue@st.com,
        peppe.cavallaro@st.com, netdev@vger.kernel.org
To: pbrobinson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48200 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751559AbcKGClc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2016 21:41:32 -0500
In-Reply-To: <20161106200437.12312-1-pbrobinson@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Robinson <pbrobinson@gmail.com>
Date: Sun,  6 Nov 2016 20:04:37 +0000

> There's not much point, except compile test, enabling the stmmac
> platform drivers unless the STM32 SoC is enabled. It's not
> useful without it.
> 
> Signed-off-by: Peter Robinson <pbrobinson@gmail.com>

Please don't post just some of the patches in a patch series.

Always post the complete series, with a proper "[PATCH 0/2] ..."
posting at the beginning.
