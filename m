From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH] isa-skelton: Remove a wrong netif_wake_queue() call
Date: Sat, 27 Feb 2010 01:13:13 +0900 (JST)
Message-ID: <20100227.011313.07637870.anemo@mba.ocn.ne.jp>
References: <1267027217-7812-1-git-send-email-anemo@mba.ocn.ne.jp>
	<20100226.015138.00843007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mv-drv-hcb003.ocn.ad.jp ([118.23.109.133]:49054 "EHLO
	mv-drv-hcb003.ocn.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965238Ab0BZQNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 11:13:20 -0500
In-Reply-To: <20100226.015138.00843007.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Feb 2010 01:51:38 -0800 (PST), David Miller <davem@davemloft.net> wrote:
> Please reference commits by also making mention of the commit
> log message header line.  This way when a patch is backported
> into another tree, people can still find it even if the
> SHA1 ID is different.  For exmaple, I fixed the above to
> read:
> 
>     This fix is ported from commit 662a96bd6f020782dfbdc0d0bd177c7dbb556687
>     ("tc35815: Remove a wrong netif_wake_queue() call which triggers BUG_ON").

Yes, I will do so next time.  Thank you.

---
Atsushi Nemoto
