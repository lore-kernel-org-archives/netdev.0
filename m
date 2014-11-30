From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netpoll: delete defconfig references to
 obsolete NETPOLL_TRAP
Date: Sat, 29 Nov 2014 21:14:01 -0800 (PST)
Message-ID: <20141129.211401.606797529833446725.davem@davemloft.net>
References: <1417102096-16537-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54929 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbaK3FJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 00:09:48 -0500
In-Reply-To: <1417102096-16537-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 27 Nov 2014 10:28:16 -0500

> In commit 9c62a68d13119a1ca9718381d97b0cb415ff4e9d ("netpoll:
> Remove dead packet receive code (CONFIG_NETPOLL_TRAP)") this
> Kconfig option was removed.  So remove references to it from
> all defconfigs as well.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks Paul.
