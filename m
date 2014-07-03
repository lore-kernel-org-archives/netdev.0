From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] drivers/net/hyperv/netvsc.c: remove unnecessary
 null test before kfree
Date: Wed, 02 Jul 2014 18:22:46 -0700 (PDT)
Message-ID: <20140702.182246.978390994509177015.davem@davemloft.net>
References: <1403981059-10189-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538AbaGCBWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 21:22:47 -0400
In-Reply-To: <1403981059-10189-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabian Frederick <fabf@skynet.be>
Date: Sat, 28 Jun 2014 20:44:19 +0200

> Fix checkpatch warning:
> WARNING: kfree(NULL) is safe this check is probably not required
> 
> Cc: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied, thanks.
