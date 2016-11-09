From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] stmmac: dwmac-rk: convert to standard
 PM/remove functions
Date: Wed, 09 Nov 2016 13:21:40 -0500 (EST)
Message-ID: <20161109.132140.1147308599056185241.davem@davemloft.net>
References: <20161105130452.24226-1-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: heiko@sntech.de, linux-rockchip@lists.infradead.org,
        vpalatin@chromium.org, peppe.cavallaro@st.com,
        netdev@vger.kernel.org
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38228 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752218AbcKISVl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:21:41 -0500
In-Reply-To: <20161105130452.24226-1-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joachim Eastwood <manabian@gmail.com>
Date: Sat,  5 Nov 2016 14:04:48 +0100

> This patch set aims to remove the init/exit callbacks from the 
> dwmac-rk driver and instead use standard PM callbacks. Eventually
> the init/exit callbacks will be deprecated and removed from all
> drivers dwmac-* except for dwmac-generic. Drivers will be refactored
> to use standard PM and remove callbacks.
> 
> This conversion was pretty straight forward, but it would really nice
> if some chromium people could test suspend/resume with this patch set.

Series applied, thank you.
