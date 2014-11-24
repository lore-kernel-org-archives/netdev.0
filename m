From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] tc_vlan: fix type of tcfv_push_vid
Date: Mon, 24 Nov 2014 16:12:19 -0500 (EST)
Message-ID: <20141124.161219.1847762149666187980.davem@davemloft.net>
References: <1416825026-4628-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbaKXVMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 16:12:21 -0500
In-Reply-To: <1416825026-4628-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 24 Nov 2014 11:30:26 +0100

> Should be u16. So fix it to kill the sparse warning.
> 
> Fixes: c7e2b9689ef8136 "sched: introduce vlan action"
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks Jiri.
