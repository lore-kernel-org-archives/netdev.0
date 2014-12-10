From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2] net: sched: cls: use nla_nest_cancel
 instead of nlmsg_trim
Date: Tue, 09 Dec 2014 21:51:53 -0500 (EST)
Message-ID: <20141209.215153.1306934686494411710.davem@davemloft.net>
References: <20141209.154849.439054105924395285.davem@davemloft.net>
	<1418160209-20001-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41363 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753650AbaLJCvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 21:51:55 -0500
In-Reply-To: <1418160209-20001-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue,  9 Dec 2014 22:23:29 +0100

> To cancel nesting, this function is more convenient.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
> v1->v2:
> - removed remaining use of b in tcindex pointed out by DaveM

This one compiles! :-)

Applied, thanks.
