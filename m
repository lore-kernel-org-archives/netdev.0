From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: distinguish EHOSTUNREACH from the ENETUNREACH
Date: Sun, 16 Feb 2014 23:46:08 -0500 (EST)
Message-ID: <20140216.234608.1386336192366153793.davem@davemloft.net>
References: <52FDEF4E.3010806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39679 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbaBQEqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Feb 2014 23:46:15 -0500
In-Reply-To: <52FDEF4E.3010806@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Fri, 14 Feb 2014 18:26:22 +0800

> since commit 251da413("ipv4: Cache ip_error() routes even when not forwarding."),
> the counter IPSTATS_MIB_INADDRERRORS can't work correctly, because the value of
> err was always set to ENETUNREACH.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied, thanks.
