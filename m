From: David Miller <davem@davemloft.net>
Subject: Re: [net-next.git] stmmac: dity-up and rework the driver debug
 levels
Date: Wed, 03 Jul 2013 15:24:38 -0700 (PDT)
Message-ID: <20130703.152438.891561060693049316.davem@davemloft.net>
References: <1372767156-12619-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38723 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118Ab3GCWYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 18:24:39 -0400
In-Reply-To: <1372767156-12619-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue,  2 Jul 2013 14:12:36 +0200

> Prior this patch, the internal debugging was based on ifdef
> and also some printk were useless because many info are exposed
> via ethtool.
> This patch remove all the ifdef defines and now we only use
> netif_msg_XXX levels.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Looks good, applied.
