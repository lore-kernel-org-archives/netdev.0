From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v3 16/20] ARM: dts: sun50i-a64: enable dwmac-sun8i on
 pine64
Date: Fri, 7 Apr 2017 14:48:47 +0200
Message-ID: <20170407124847.GA15546@Red>
References: <20170403091444.29876-1-clabbe.montjoie@gmail.com>
 <20170403091444.29876-17-clabbe.montjoie@gmail.com>
 <20170403113847.dca2tetjit7xoxyn@lukather>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, mark.rutland@arm.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35455 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754710AbdDGMsw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 08:48:52 -0400
Content-Disposition: inline
In-Reply-To: <20170403113847.dca2tetjit7xoxyn@lukather>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 03, 2017 at 01:38:47PM +0200, Maxime Ripard wrote:
> On Mon, Apr 03, 2017 at 11:14:40AM +0200, Corentin Labbe wrote:
> > The dwmac-sun8i hardware is present on the pine64
> > It uses an external PHY via RMII.
> > 
> > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> 
> Looks fine, but please use "arm64: allwinner: pine64: " as your title
> prefix. It applies to all your other patches (and the arm ones should
> be "arm: <family>: <soc-or-board>:".
> 

Will fix them

Thanks
Corentin Labbe
