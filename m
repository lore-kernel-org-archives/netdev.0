From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: platform: fix default values of the filter
 bins setting
Date: Wed, 26 Nov 2014 12:29:21 -0500 (EST)
Message-ID: <20141126.122921.2229047704394133858.davem@davemloft.net>
References: <1416969486-9047-1-git-send-email-chenhc@lemote.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, vbridgers2013@gmail.com,
	netdev@vger.kernel.org
To: chenhc@lemote.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48913 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbaKZR3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 12:29:23 -0500
In-Reply-To: <1416969486-9047-1-git-send-email-chenhc@lemote.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huacai Chen <chenhc@lemote.com>
Date: Wed, 26 Nov 2014 10:38:06 +0800

> The commit 3b57de958e2a brought the support for a different amount of
> the filter bins, but didn't update the platform driver that without
> CONFIG_OF.
> 
> Fixes: 3b57de958e2a (net: stmmac: Support devicetree configs for mcast
> and ucast filter entries)
> 
> Signed-off-by: Huacai Chen <chenhc@lemote.com>

Applied, thanks.
