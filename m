From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: sched: pkt_cls: remove unused macros from
 uapi
Date: Thu, 21 May 2015 23:27:17 -0400 (EDT)
Message-ID: <20150521.232717.526011561851102537.davem@davemloft.net>
References: <1432167984-3612-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42321 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755960AbbEVD1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 23:27:18 -0400
In-Reply-To: <1432167984-3612-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 21 May 2015 02:26:24 +0200

> Jamal points out that this header also contains kernel internal magic that
> cannot be used from userspace for anything meaningful.
> 
> Lets remove what the kernel doesn't use anymore and wrap remainder with
> __KERNEL__.
> 
> Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Suggested-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks.
