From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: dwmac-rk: Don't add function name in info
 or err messages
Date: Thu, 18 Jun 2015 03:31:51 -0700 (PDT)
Message-ID: <20150618.033151.447730490306007318.davem@davemloft.net>
References: <1434390259-27145-1-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-rockchip@lists.infradead.org
To: romain.perier@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41208 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754641AbbFRKUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 06:20:10 -0400
In-Reply-To: <1434390259-27145-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Romain Perier <romain.perier@gmail.com>
Date: Mon, 15 Jun 2015 17:44:19 +0000

> These kind of informations are only useful for debugging and should not be
> displayed in normal modules message.
> 
> Signed-off-by: Romain Perier <romain.perier@gmail.com>

Applied.
