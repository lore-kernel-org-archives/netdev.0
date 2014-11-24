From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: coding style improvements (remove
 assignment in if statements)
Date: Sun, 23 Nov 2014 21:01:13 -0500 (EST)
Message-ID: <20141123.210113.116994251976473168.davem@davemloft.net>
References: <1416778123-5803-1-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ipm@chirality.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbaKXCBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 21:01:15 -0500
In-Reply-To: <1416778123-5803-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>
Date: Sun, 23 Nov 2014 21:28:43 +0000

> This change has no functional impact and simply addresses some coding
> style issues detected by checkpatch. Specifically this change
> adjusts "if" statements which also include the assignment of a
> variable.
> 
> No changes to the resultant object files result as determined by objdiff.
> 
> Signed-off-by: Ian Morris <ipm@chirality.org.uk>

Applied, thanks.
