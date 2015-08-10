From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: select copper mode when Marvel 88e1111 in
 SGMII
Date: Mon, 10 Aug 2015 13:31:33 -0700 (PDT)
Message-ID: <20150810.133133.908518123684909196.davem@davemloft.net>
References: <1438938470-5776-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, madalin.bucur@freescale.com,
	Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932491AbbHJUbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 16:31:34 -0400
In-Reply-To: <1438938470-5776-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Fri, 7 Aug 2015 17:07:50 +0800

> From: Madalin Bucur <madalin.bucur@freescale.com>
> 
> For the Marvel 88e1111 PHY only two SGMII modes are available, both
> allowing only SGMII to copper mode (with or without clock). SGMII
> to fiber mode is not supported. Make sure the fiber/copper registers
> selector bits are cleared for selecting copper mode.
> 
> Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>

Applied, thanks.
