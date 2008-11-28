From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: fix sparse warning
Date: Fri, 28 Nov 2008 03:07:07 -0800 (PST)
Message-ID: <20081128.030707.31836881.davem@davemloft.net>
References: <492fbbfd.190c660a.1db3.fffffcc3@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57723
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752277AbYK1LHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 06:07:07 -0500
In-Reply-To: <492fbbfd.190c660a.1db3.fffffcc3@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Thu, 27 Nov 2008 20:33:17 +0100

> Impact: make global function static
> 
> Fix the following sparse warning:
> 
>   net/sched/sch_api.c:192:14: warning: symbol 'qdisc_match_from_root' was not declared. Should it be static?
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied, thanks Hannes.
