From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Fix sparse warnings.
Date: Tue, 02 Oct 2012 23:22:09 -0400 (EDT)
Message-ID: <20121002.232209.521171138659193934.davem@davemloft.net>
References: <1349235074-18927-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53429 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112Ab2JCDWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 23:22:10 -0400
In-Reply-To: <1349235074-18927-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 2 Oct 2012 20:31:14 -0700

> drivers/net/ethernet/broadcom/tg3.c:8121:8: warning: symbol 'i' shadows an earlier one
> drivers/net/ethernet/broadcom/tg3.c:8003:6: originally declared here
> drivers/net/ethernet/broadcom/tg3.c:785:5: warning: symbol 'tg3_ape_scratchpad_read' was not declared. Should it be static?
> drivers/net/ethernet/broadcom/tg3.c:7781:19: warning: Using plain integer as NULL pointer
> drivers/net/ethernet/broadcom/tg3.c:10231:31: error: bad constant expression
> 
> Reported-by: Fengguang Wu <fenguang.wu@intel.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
