From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] stmmac: Allow SOCs to use Store forward mode
 eventhough tx_coe is 0. (V2)
Date: Mon, 18 Jul 2011 10:47:45 -0700 (PDT)
Message-ID: <20110718.104745.1448178149936567649.davem@davemloft.net>
References: <1310972049-827-1-git-send-email-peppe.cavallaro@st.com>
	<1310972049-827-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, srinivas.kandagatla@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58385 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991Ab1GRRrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 13:47:51 -0400
In-Reply-To: <1310972049-827-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon, 18 Jul 2011 08:54:09 +0200

> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> 
> This patch adds new field 'force_sf_dma_mode' to plat_stmmacenet_data
> struct to allow users to specify if they want to use force store forward
> eventhough tx_coe is not available in hw.
> without this flag stmmac driver will use cut-thru mode not use
> store-forward mode.
> 
> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
