From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: devm_reset_control_get can return PROBE_DEFER
Date: Thu, 09 Apr 2015 14:11:32 -0400 (EDT)
Message-ID: <20150409.141132.2053854204798602746.davem@davemloft.net>
References: <1428543694-41762-1-git-send-email-preid@electromag.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: preid@electromag.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49546 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755531AbbDISLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 14:11:34 -0400
In-Reply-To: <1428543694-41762-1-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Reid <preid@electromag.com.au>
Date: Wed,  8 Apr 2015 18:41:34 -0700

> In socfpga_dwmac_parse_data forward error code from devm_reset_control_get.
> This gives the driver another chance to laod if altr,rst-mgr is loaded after
> the network driver.
> 
> Signed-off-by: Phil Reid <preid@electromag.com.au>

Applied, thanks.
