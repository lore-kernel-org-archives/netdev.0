From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] net:stmmac: fix memleak in the open method
Date: Thu, 04 Jul 2013 14:34:46 -0700 (PDT)
Message-ID: <20130704.143446.1077541579238614589.davem@davemloft.net>
References: <1372911487-18472-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50950 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756900Ab3GDVer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 17:34:47 -0400
In-Reply-To: <1372911487-18472-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu,  4 Jul 2013 06:18:07 +0200

> This patch is to fix a memory leak in the open method, it reviews error
> conditions freeing the resources previously allocated and not freed in
> cased of DMA failure.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
