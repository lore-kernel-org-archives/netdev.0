From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/1] sched,cls_flower: set key address type
 when present
Date: Mon, 11 Jan 2016 17:28:04 -0500 (EST)
Message-ID: <20160111.172804.1878910043638374783.davem@davemloft.net>
References: <1452444421-3939-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933657AbcAKW2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 17:28:06 -0500
In-Reply-To: <1452444421-3939-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sun, 10 Jan 2016 11:47:01 -0500

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> only when user space passes the addresses should we consider their
> presence
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Acked-by: Jiri Pirko <jiri@resnulli.us>

Applied to 'net' and queued up for -stable, thanks.
