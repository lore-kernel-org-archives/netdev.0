From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/2] stmmac: fix autoneg in set_pauseparam
Date: Fri, 13 May 2011 16:12:24 -0400 (EDT)
Message-ID: <20110513.161224.183882811401088990.davem@davemloft.net>
References: <1305268085-603-1-git-send-email-peppe.cavallaro@st.com>
	<1305268085-603-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178Ab1EMUMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 16:12:30 -0400
In-Reply-To: <1305268085-603-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Fri, 13 May 2011 08:28:05 +0200

> This patch fixes a bug in the set_pauseparam
> function that didn't well manage the ANE
> field and returned broken values when use
> ethtool -A|-a.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
