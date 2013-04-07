From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] stmmac: modified pcs mode support for SGMII
Date: Sun, 07 Apr 2013 17:08:46 -0400 (EDT)
Message-ID: <20130407.170846.2105935127378498264.davem@davemloft.net>
References: <00b401ce30f9$3a628c50$af27a4f0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	kgene.kim@samsung.com, cpgs@samsung.com
To: bh74.an@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934238Ab3DGVIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 17:08:48 -0400
In-Reply-To: <00b401ce30f9$3a628c50$af27a4f0$%an@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Byungho An <bh74.an@samsung.com>
Date: Thu, 04 Apr 2013 14:57:01 +0900

> This patch modifies the pcs mode support for SGMII. Even though
> SGMII does auto-negotiation with phy, it needs stmmac_init_phy and
> stmmac_mdio_register function for initializing phy.
> 
> Signed-off-by: Byungho An <bh74.an@samsung.com>

Your email client corrupted this patch, it turned all TAB characters
into spaces.  This makes your submission unusable.

Please fix this, email the patch to yourself, and only resubmit the
patch here if you are able to successfully apply the patch you receive
in a test email.
