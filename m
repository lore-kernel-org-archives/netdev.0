From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/17] stmmac clean up for 4.3 part2
Date: Wed, 29 Jul 2015 00:13:54 -0700 (PDT)
Message-ID: <20150729.001354.861107528589588129.davem@davemloft.net>
References: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	b.galvani@gmail.com, arnd@arndb.de, roger.chen@rock-chips.com,
	heiko@sntech.de, wens@csie.org, dinguyen@opensource.altera.com,
	linux-rockchip@lists.infradead.org, mathieu@codeaurora.org
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56732 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414AbbG2HN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 03:13:56 -0400
In-Reply-To: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joachim Eastwood <manabian@gmail.com>
Date: Wed, 29 Jul 2015 00:08:47 +0200

> This patch set creates proper probe functions in the remaining
> dwmac-* drivers, lets the drivers manage their own of match data
> structure, and cleans up some of the drivers a bit. Note that
> should be no functional change in any of the drivers.

This is a really nice set of simplifications, series applied, thanks.

Please follow up on any breakage reported, thanks.
