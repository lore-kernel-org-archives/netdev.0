From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: Add missing LF to pr_info() in stmmac_main.c
Date: Tue, 10 Jan 2012 14:57:33 -0800 (PST)
Message-ID: <20120110.145733.171422305250705872.davem@davemloft.net>
References: <1326196071-10341-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com
To: sr@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46912 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933117Ab2AJW5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 17:57:44 -0500
In-Reply-To: <1326196071-10341-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Roese <sr@denx.de>
Date: Tue, 10 Jan 2012 12:47:51 +0100

> Otherwise the output looks like this:
> 
> ...
> STMMAC - user ID: 0x10, Synopsys ID: 0x32
>  No HW DMA feature register supported
>  Normal descriptors
>  Remote wake-up capable
>  Checksum Offload Engine supported
>  No MAC Management Counters availableIP-Config: Complete:
>      device=eth0, addr=192.168.20.42, mask=255.255.0.0, gw=192.168.1.254,
> ...
> 
> Signed-off-by: Stefan Roese <sr@denx.de>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
