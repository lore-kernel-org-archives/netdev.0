From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] l2tp: fix missing line continuation
Date: Fri, 05 Sep 2014 15:20:18 -0700 (PDT)
Message-ID: <20140905.152018.2278971964117052672.davem@davemloft.net>
References: <1409775414-11568-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: azhou@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbaIEWUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 18:20:19 -0400
In-Reply-To: <1409775414-11568-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>
Date: Wed,  3 Sep 2014 13:16:54 -0700

> This syntax error was covered by L2TP_REFCNT_DEBUG not being set by
> default.
> 
> Signed-off-by: Andy Zhou <azhou@nicira.com>

Applied, thanks Andy.
