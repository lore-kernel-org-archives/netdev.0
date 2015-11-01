From: David Miller <davem@davemloft.net>
Subject: Re: [1/1] stmmac: Correctly report PTP capabilities.
Date: Sun, 01 Nov 2015 17:06:16 -0500 (EST)
Message-ID: <20151101.170616.2211861253361543823.davem@davemloft.net>
References: <1446194635-19782-1-git-send-email-preid@electromag.com.au>
	<1446194635-19782-2-git-send-email-preid@electromag.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: preid@electromag.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55450 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752672AbbKAWGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 17:06:18 -0500
In-Reply-To: <1446194635-19782-2-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Reid <preid@electromag.com.au>
Date: Fri, 30 Oct 2015 16:43:55 +0800

> priv->hwts_*_en indicate if timestamping is enabled/disabled at run
> time. But  priv->dma_cap.time_stamp  and priv->dma_cap.atime_stamp
> indicates HW is support for PTPv1/PTPv2.
> 
> Signed-off-by: Phil Reid <preid@electromag.com.au>

Applied and queued up for -stable, thanks.
