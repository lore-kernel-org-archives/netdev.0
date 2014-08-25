From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 1/2] stmmac: fix rx checksum programming
Date: Mon, 25 Aug 2014 15:33:20 -0700 (PDT)
Message-ID: <20140825.153320.1457146756644269860.davem@davemloft.net>
References: <1408971379-14871-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38629 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752917AbaHYWdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 18:33:21 -0400
In-Reply-To: <1408971379-14871-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Mon, 25 Aug 2014 14:56:18 +0200

> This patch is to fix the IPC bit into the GMAC control register
> that must be done after the core initialization otherwise it will
> not have any effect.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
