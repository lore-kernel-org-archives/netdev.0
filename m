From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3b 1/3] tipc: cosmetic: clean up comments and break a
 long line
Date: Wed, 01 May 2013 13:16:02 -0400 (EDT)
Message-ID: <20130501.131602.899596493606702378.davem@davemloft.net>
References: <51814058.3080805@cogentembedded.com>
	<1367426477-10441-1-git-send-email-gerlando.falauto@keymile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	jon.maloy@ericsson.com, erik.hugne@ericsson.com,
	ying.xue@windriver.com, holger.brunck@keymile.com
To: gerlando.falauto@keymile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887Ab3EARQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 13:16:06 -0400
In-Reply-To: <1367426477-10441-1-git-send-email-gerlando.falauto@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerlando Falauto <gerlando.falauto@keymile.com>
Date: Wed,  1 May 2013 18:41:17 +0200

> Signed-off-by: Gerlando Falauto <gerlando.falauto@keymile.com>
> ---
> Changes from v3:
> * Added "and break a long line" to the commit message
> Changes from v2:
> * Split cosmetic (this patch) from functional changes (next patch)

Never resubmit patches by themselves, always resubmit the entire series.

Because when one patch has problems, I toss the entire series from patchwork,
and by resubmitting the entire series again you are also giving me important
information, you're telling me that the subsequent patches in the series
still apply cleanly even though the first one has changed.

I've tossed this patch too, resubmit this properly, thanks.
