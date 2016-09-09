From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 3/9] ARM: sun8i: dt: Add DT bindings documentation for
 Allwinner sun8i-emac
Date: Fri, 9 Sep 2016 16:17:10 +0200
Message-ID: <20160909141710.GF30871@lunn.ch>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
 <1473425117-18645-4-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        devicetree@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40092 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750744AbcIIORo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Sep 2016 10:17:44 -0400
Content-Disposition: inline
In-Reply-To: <1473425117-18645-4-git-send-email-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +Optional properties:
> +- allwinner,tx-delay: TX clock delay chain value. Range value is 0-0x07. Default is 0)
> +- allwinner,rx-delay: RX clock delay chain value. Range value is 0-0x1F. Default is 0)

What are the units? pS? nS?

     Andrew
