From: David Miller <davem@davemloft.net>
Subject: Re: [net-next.git 0/4] EEE for PAL and stmmac (V7)
Date: Sun, 01 Jul 2012 03:37:38 -0700 (PDT)
Message-ID: <20120701.033738.1785276201269043562.davem@davemloft.net>
References: <1340867678-18375-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	rayagond@vayavyalabs.com, yuvalmin@broadcom.com,
	bhutchings@solarflare.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47664 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090Ab2GAKhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 06:37:39 -0400
In-Reply-To: <1340867678-18375-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 28 Jun 2012 09:14:34 +0200

> Giuseppe Cavallaro (4):
>   stmmac: do not use strict_strtoul but kstrtoint
>   stmmac: update the driver Documentation and add EEE
>   stmmac: add the Energy Efficient Ethernet support
>   phy: add the EEE support and the way to access to the MMD registers.

Series applied, thanks.
