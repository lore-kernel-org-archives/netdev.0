From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: sch_qfq: remove redundant -if- control
 statement
Date: Mon, 15 Jun 2015 17:20:08 -0700 (PDT)
Message-ID: <20150615.172008.2143967850726126681.davem@davemloft.net>
References: <20150615122001.GA5600@andrea>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, paolo.valente@unimore.it, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: parri.andrea@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42835 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbbFPAUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 20:20:10 -0400
In-Reply-To: <20150615122001.GA5600@andrea>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrea Parri <parri.andrea@gmail.com>
Date: Mon, 15 Jun 2015 14:20:01 +0200

> The control !hlist_unhashed() in qfq_destroy_agg() is unnecessary
> because already performed in hlist_del_init(), so remove it.
> 
> Signed-off-by: Andrea Parri <parri.andrea@gmail.com>

This patch has been corrupted by your email client (TAB characters
have been transformed into sequences of SPACEs, etc.)

Please fix this up and resubmit.
