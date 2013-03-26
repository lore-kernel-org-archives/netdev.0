From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net/davinci_emac: use
 clk_{prepare|unprepare}
Date: Tue, 26 Mar 2013 12:29:12 -0400 (EDT)
Message-ID: <20130326.122912.2193051620893427218.davem@davemloft.net>
References: <1364203547-2960-3-git-send-email-nsekhar@ti.com>
	<20130325161654.4014.68401@quantum>
	<515172F7.3050600@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mturquette@linaro.org, netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com, rjw@sisk.pl
To: nsekhar@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981Ab3CZQ3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:29:14 -0400
In-Reply-To: <515172F7.3050600@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sekhar Nori <nsekhar@ti.com>
Date: Tue, 26 Mar 2013 15:35:43 +0530

> This patch can then be dropped for now, but 1/2 can still be applied.
> That one is pretty harmless!

I've applied it.
