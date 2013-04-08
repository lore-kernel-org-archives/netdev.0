From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RESEND] stmmac: modified pcs mode support for
 SGMII
Date: Mon, 08 Apr 2013 16:57:11 -0400 (EDT)
Message-ID: <20130408.165711.439277485659328988.davem@davemloft.net>
References: <015701ce340d$052a71d0$0f7f5570$%an@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	kgene.kim@samsung.com, cpgs@samsung.com
To: bh74.an@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964971Ab3DHU5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 16:57:13 -0400
In-Reply-To: <015701ce340d$052a71d0$0f7f5570$%an@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Byungho An <bh74.an@samsung.com>
Date: Mon, 08 Apr 2013 12:56:16 +0900

> 
> This patch modifies the pcs mode support for SGMII. Even though
> SGMII does auto-negotiation with phy, it needs stmmac_init_phy and
> stmmac_mdio_register function for initializing phy.
> 
> Signed-off-by: Byungho An <bh74.an@samsung.com>

Applied.
