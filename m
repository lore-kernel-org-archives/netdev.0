From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: replace strict_strtoul() with kstrtoul()
Date: Mon, 03 Jun 2013 00:41:06 -0700 (PDT)
Message-ID: <20130603.004106.1516643429664432072.davem@davemloft.net>
References: <000e01ce5e98$a65d5ee0$f3181ca0$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, manish.chopra@qlogic.com,
	sony.chacko@qlogic.com, rajesh.borundia@qlogic.com,
	shahed.shaikh@qlogic.com, jitendra.kalsaria@qlogic.com,
	linux-driver@qlogic.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38164 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312Ab3FCHlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 03:41:07 -0400
In-Reply-To: <000e01ce5e98$a65d5ee0$f3181ca0$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Sat, 01 Jun 2013 16:21:35 +0900

> The usage of strict_strtoul() is not preferred, because
> strict_strtoul() is obsolete. Thus, kstrtoul() should be
> used.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
