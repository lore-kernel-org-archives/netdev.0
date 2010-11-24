From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] stmmac: add init/exit callback in
 plat_stmmacenet_data struct
Date: Wed, 24 Nov 2010 11:14:46 -0800 (PST)
Message-ID: <20101124.111446.48519587.davem@davemloft.net>
References: <1290561646-9429-1-git-send-email-peppe.cavallaro@st.com>
	<1290561646-9429-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38161
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754854Ab0KXTOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 14:14:20 -0500
In-Reply-To: <1290561646-9429-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 24 Nov 2010 13:38:05 +0100

> This patch adds in the plat_stmmacenet_data
> the init and exit callbacks that can be used
> for invoking specific platform functions.
> For example, on ST targets, these call the
> PAD manager functions to set PIO lines and
> syscfg registers.
> The patch removes the stmmac_claim_resource
> only used on STM Kernels as well.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
