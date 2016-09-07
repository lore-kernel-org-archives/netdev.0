From: Stephen Boyd <sboyd@codeaurora.org>
Subject: Re: [PATCH v5 2/6] clk: gxbb: expose MPLL2 clock for use by DT
Date: Wed, 7 Sep 2016 14:27:20 -0700
Message-ID: <20160907212720.GZ12510@codeaurora.org>
References: <20160904182320.671-1-martin.blumenstingl@googlemail.com>
 <20160906213848.17785-1-martin.blumenstingl@googlemail.com>
 <20160906213848.17785-3-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-amlogic@lists.infradead.org, khilman@baylibre.com,
        carlo@caione.org, mturquette@baylibre.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, manabian@gmail.com,
        arnd@arndb.de, davem@davemloft.net, b.galvani@gmail.com
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:52064 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750772AbcIGV1W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 17:27:22 -0400
Content-Disposition: inline
In-Reply-To: <20160906213848.17785-3-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06, Martin Blumenstingl wrote:
> This exposes the MPLL2 clock as this is one of the input clocks of the
> ethernet controller's internal mux.
> 
> Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
> ---

Acked-by: Stephen Boyd <sboyd@codeaurora.org>

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project
