From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v9 00/10] net: stmmac: dwmac-sun8i: Handle integrated
 PHY
Date: Fri, 27 Oct 2017 12:01:20 +0900 (KST)
Message-ID: <20171027.120120.2234388600545678888.davem@davemloft.net>
References: <20171024175714.15840-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43570 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751584AbdJ0DB0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 23:01:26 -0400
In-Reply-To: <20171024175714.15840-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Tue, 24 Oct 2017 19:57:04 +0200

> The first 7 patch should go via the sunxi tree, the last three via
> the net tree.

I've applied the last 3 patches to net-next.
