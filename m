From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/27] drivers/net/ethernet/stmicro/stmmac: don't check
 resource with devm_ioremap_resource
Date: Wed, 24 Jul 2013 23:59:46 -0700 (PDT)
Message-ID: <20130724.235946.2251164173355173515.davem@davemloft.net>
References: <1374602524-3398-1-git-send-email-wsa@the-dreams.de>
	<1374602524-3398-13-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, peppe.cavallaro@st.com,
	netdev@vger.kernel.org
To: wsa@the-dreams.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39834 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854Ab3GYG7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 02:59:47 -0400
In-Reply-To: <1374602524-3398-13-git-send-email-wsa@the-dreams.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfram Sang <wsa@the-dreams.de>
Date: Tue, 23 Jul 2013 20:01:45 +0200

> devm_ioremap_resource does sanity checks on the given resource. No need to
> duplicate this in the driver.
> 
> Signed-off-by: Wolfram Sang <wsa@the-dreams.de>

Applied, thanks.
