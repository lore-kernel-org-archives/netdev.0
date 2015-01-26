From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] stmmac: if force_thresh_dma_mode is set, pass tc
 to both txmode and rxmode in tx_hard_error_bump_tc interrupt
Date: Mon, 26 Jan 2015 15:48:26 -0800 (PST)
Message-ID: <20150126.154826.2264824730267584906.davem@davemloft.net>
References: <1421909758-31359-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	adi-buildroot-devel@lists.sourceforge.net, sonic.zhang@analog.com
To: sonic.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46203 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496AbbA0AYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:24:01 -0500
In-Reply-To: <1421909758-31359-1-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.adi@gmail.com>
Date: Thu, 22 Jan 2015 14:55:56 +0800

> From: Sonic Zhang <sonic.zhang@analog.com>
> 
> Dont' pass SF_DMA_MODE to rxmode in this case.
> 
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>

Applied.
