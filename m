From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: remove orphaned references to micro
 channel
Date: Sun, 06 Jan 2013 21:13:48 -0800 (PST)
Message-ID: <20130106.211348.1999152444992940682.davem@davemloft.net>
References: <1357354637-1784-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176Ab3AGFNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 00:13:48 -0500
In-Reply-To: <1357354637-1784-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri,  4 Jan 2013 21:57:17 -0500

> We threw away the microchannel support, but the removal wasn't
> completely trivial since there was namespace overlap with the
> machine check support, and hence some orphaned dependencies
> survived the deletion.  This attempts to sweep those up and
> send them to the bit-bucket.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks.
