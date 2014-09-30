From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Allow for receive of full-size 8021AD frames
Date: Tue, 30 Sep 2014 17:02:25 -0400 (EDT)
Message-ID: <20140930.170225.774129857270025245.davem@davemloft.net>
References: <1411165389-21276-1-git-send-email-vyasevic@redhat.com>
	<542AFC14.6030304@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, prashant@broadcom.com, mchan@broadcom.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49847 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbaI3VC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 17:02:27 -0400
In-Reply-To: <542AFC14.6030304@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Tue, 30 Sep 2014 14:53:08 -0400

> This patch somehow got dropped.  Please apply and queue for stable.

Because I applied your original patch:

	http://patchwork.ozlabs.org/patch/390834/

This patch here doesn't even apply to the 'net' tree because of that.

Please sort that out.

I'm marking this patch and the similar bnx2 one 'deferred'.  Please
resubmit everything once you've sorted things out.

Thanks.
