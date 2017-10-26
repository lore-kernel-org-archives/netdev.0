From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v9 04/10] arm: dts: sunxi: h3/h5: represent the mdio
 switch used by sun8i-h3-emac
Date: Thu, 26 Oct 2017 11:54:11 +0200
Message-ID: <20171026095411.GJ20299@lunn.ch>
References: <20171024175714.15840-1-clabbe.montjoie@gmail.com>
 <20171024175714.15840-5-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:58477 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751263AbdJZJyR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 05:54:17 -0400
Content-Disposition: inline
In-Reply-To: <20171024175714.15840-5-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 24, 2017 at 07:57:08PM +0200, Corentin Labbe wrote:
> Since dwmac-sun8i could use either an integrated PHY or an external PHY
> (which could be at same MDIO address), we need to represent this selection
> by a MDIO switch.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
