From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/10] tipc: cleanups, fixes & improvements
 for topology server
Date: Sat, 06 Feb 2016 03:42:30 -0500 (EST)
Message-ID: <20160206.034230.626548570881974193.davem@davemloft.net>
References: <1454406737-5806-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, maloy@donjonn.com, ying.xue@windriver.com
To: parthasarathy.bhuvaragan@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbcBFIme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 03:42:34 -0500
In-Reply-To: <1454406737-5806-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Date: Tue, 2 Feb 2016 10:52:07 +0100

> This series contains topology server cleanups, fixes and improvements.
> 
> Cleanups in #1-#4:
> We remove duplicate data structures and aligin the rest of the code accordingly.
> 
> Fixes in #5-#8:
> The bugs occur either during configuration or while running on SMP targets,
> which are race conditions that pop up under different situations.
> 
> Improvements in #9-#10:
> Updates to decrease timer usage and improve readability.
> 
> v2: Updated commit message in patch 6 based on feedback from
>     Sergei Shtylyov sergei.shtylyov@cogentembedded.com

Series applied, thanks.
