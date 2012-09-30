From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7 net-next v2] tg3: Refactor tg3_close()
Date: Sun, 30 Sep 2012 02:12:39 -0400 (EDT)
Message-ID: <20120930.021239.1085362850743389627.davem@davemloft.net>
References: <1348852363-8582-3-git-send-email-mchan@broadcom.com>
	<1348852363-8582-4-git-send-email-mchan@broadcom.com>
	<1348852363-8582-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243Ab2I3GMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2012 02:12:40 -0400
In-Reply-To: <1348852363-8582-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 28 Sep 2012 10:12:41 -0700

> by introducing tg3_stop() that does the opposite of tg3_start().  This
> function will be useful when adding the support for changing the numbe
> of rx and tx rings.
> 
> Reviewed-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Reviewed-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
