From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: act_ipt forward compat with xtables
Date: Wed, 01 May 2013 13:20:23 -0400 (EDT)
Message-ID: <20130501.132023.2197014617494654230.davem@davemloft.net>
References: <517D3AFE.8020001@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemonc@gmail.com, jengelh@inai.de
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342Ab3EARU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 13:20:26 -0400
In-Reply-To: <517D3AFE.8020001@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sun, 28 Apr 2013 11:06:38 -0400

> When Hasan nods I think this should also go into stable because none
> of the newer kernels work with newer iptables (which is a lot of
> distros).

I'm tired waiting, applied and queued up for -stable, thanks Jamal.
