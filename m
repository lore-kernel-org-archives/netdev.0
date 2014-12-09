From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/2] net: sched: cls: use nla_nest_cancel
 instead of nlmsg_trim
Date: Tue, 09 Dec 2014 15:42:18 -0500 (EST)
Message-ID: <20141209.154218.95904353076153825.davem@davemloft.net>
References: <1417791023-28124-1-git-send-email-jiri@resnulli.us>
	<1417791023-28124-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbaLIUmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 15:42:21 -0500
In-Reply-To: <1417791023-28124-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  5 Dec 2014 15:50:23 +0100

> To cancel nesting, this function is more convenient.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied.
