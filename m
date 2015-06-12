From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdevice: add netdev_pub helper function
Date: Fri, 12 Jun 2015 14:20:58 -0700 (PDT)
Message-ID: <20150612.142058.1085284048217032168.davem@davemloft.net>
References: <1434115829-22804-1-git-send-email-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason@zx2c4.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47446 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbbFLVU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 17:20:59 -0400
In-Reply-To: <1434115829-22804-1-git-send-email-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Fri, 12 Jun 2015 15:30:29 +0200

> Being able to utilize this makes much code a lot simpler and cleaner.
> It's a nice convenience function.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

Please do not ever submit patches adding new interfaces without
also submitting changes showing actual uses of the new interface.

Otherwise it's impossible to see how really useful it actually
is.

I'm not applying this until you do so, thanks.
