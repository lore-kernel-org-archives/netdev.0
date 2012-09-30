From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7 net-next v2] tg3: Refactor tg3_open()
Date: Sun, 30 Sep 2012 02:12:33 -0400 (EDT)
Message-ID: <20120930.021233.893051459486438328.davem@davemloft.net>
References: <1348852363-8582-2-git-send-email-mchan@broadcom.com>
	<1348852363-8582-3-git-send-email-mchan@broadcom.com>
	<1348852363-8582-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54929 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173Ab2I3GMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2012 02:12:34 -0400
In-Reply-To: <1348852363-8582-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 28 Sep 2012 10:12:40 -0700

> by introducing tg3_start() that handles all initialization steps from
> IRQ allocation.  This function will be needed when adding support for
> changing the number of rx and tx rings.
> 
> Reviewed-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Reviewed-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
