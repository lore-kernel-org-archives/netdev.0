From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tg3: Add skb->xmit_more support
Date: Tue, 14 Oct 2014 15:34:34 -0400 (EDT)
Message-ID: <20141014.153434.1729817203609917136.davem@davemloft.net>
References: <1413217302-15396-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com, mchan@broadcom.com
To: prashant@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43971 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932276AbaJNTeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 15:34:36 -0400
In-Reply-To: <1413217302-15396-1-git-send-email-prashant@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashant Sreedharan <prashant@broadcom.com>
Date: Mon, 13 Oct 2014 09:21:42 -0700

> Ring TX doorbell only if xmit_more is not set or the queue is stopped.
> 
> Suggested-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
