From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: stmmac: dwmac-rk: Add rv1108 gmac
 support
Date: Tue, 22 Aug 2017 10:31:11 -0700 (PDT)
Message-ID: <20170822.103111.606080308323162004.davem@davemloft.net>
References: <1503310375-30393-1-git-send-email-david.wu@rock-chips.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: heiko@sntech.de, robh+dt@kernel.org, linux@armlinux.org.uk,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, netdev@vger.kernel.org,
        linux-rockchip@lists.infradead.org, linux-kernel@vger.kernel.org
To: david.wu@rock-chips.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38532 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751763AbdHVRbM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 13:31:12 -0400
In-Reply-To: <1503310375-30393-1-git-send-email-david.wu@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Wu <david.wu@rock-chips.com>
Date: Mon, 21 Aug 2017 18:12:55 +0800

> It only supports rmii interface. Add constants and callback functions
> for the dwmac on rv1108 socs. As can be seen, the base structure is
> the same, only registers and the bits in them moved slightly.
> 
> Signed-off-by: David Wu <david.wu@rock-chips.com>

Applied, thanks.
