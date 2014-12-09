From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: sched: cls: remove unused op put from
 tcf_proto_ops
Date: Tue, 09 Dec 2014 14:49:14 -0500 (EST)
Message-ID: <20141209.144914.808097916610922518.davem@davemloft.net>
References: <1417725678-24968-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752467AbaLITtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 14:49:16 -0500
In-Reply-To: <1417725678-24968-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  4 Dec 2014 21:41:18 +0100

> It is never called and implementations are void. So just remove it.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks.
