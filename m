From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ssb: sprom: replace strict_strtoul() with kstrtoul()
Date: Mon, 03 Jun 2013 00:41:17 -0700 (PDT)
Message-ID: <20130603.004117.616178751049025102.davem@davemloft.net>
References: <001601ce5e9a$93bc9fb0$bb35df10$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: m@bues.ch, netdev@vger.kernel.org, linville@tuxdriver.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38176 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682Ab3FCHlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 03:41:19 -0400
In-Reply-To: <001601ce5e9a$93bc9fb0$bb35df10$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Sat, 01 Jun 2013 16:35:23 +0900

> The usage of strict_strtoul() is not preferred, because
> strict_strtoul() is obsolete. Thus, kstrtoul() should be
> used.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
