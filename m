From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] tun: Some bits required for tun's
 checkpoint-restore (v2)
Date: Wed, 21 Aug 2013 12:22:16 -0700 (PDT)
Message-ID: <20130821.122216.1807509682689007989.davem@davemloft.net>
References: <521496EF.8090909@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35436 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127Ab3HUTWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 15:22:17 -0400
In-Reply-To: <521496EF.8090909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Wed, 21 Aug 2013 14:31:11 +0400

> After taking a closer look on tun checkpoint-restore I've found several
> issues with the tun's API that make it impossible to dump and restore
> the state of tun device and attached tun-files.
> 
> The proposed API changes are all about extending the existing ioctl-based
> stuff. Patches fit today's net-next.
> 
> This v2 has David's comments about patch #1 fixed. All the rest is the same.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Series applied, thanks.
