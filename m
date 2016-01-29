From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/22] net: Fix dependencies for !HAS_IOMEM archs
Date: Thu, 28 Jan 2016 16:03:31 -0800 (PST)
Message-ID: <20160128.160331.2002092613365281922.davem@davemloft.net>
References: <1453760661-1444-1-git-send-email-richard@nod.at>
	<1453760661-1444-14-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	user-mode-linux-devel@lists.sourceforge.net, f.fainelli@gmail.com,
	talz@ezchip.com, abrodkin@synopsys.com, noamc@ezchip.com,
	netdev@vger.kernel.org
To: richard@nod.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60022 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbcA2ADc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 19:03:32 -0500
In-Reply-To: <1453760661-1444-14-git-send-email-richard@nod.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Weinberger <richard@nod.at>
Date: Mon, 25 Jan 2016 23:24:12 +0100

> Not every arch has io memory.
> So, unbreak the build by fixing the dependencies.
> 
> Signed-off-by: Richard Weinberger <richard@nod.at>

Applied.
