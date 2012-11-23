From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch] tun: change tun_get_iff() prototype.
Date: Fri, 23 Nov 2012 14:25:21 -0500 (EST)
Message-ID: <20121123.142521.169150450341859481.davem@davemloft.net>
References: <1353679090-27892-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maxk@qualcomm.com, netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754097Ab2KWTZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 14:25:25 -0500
In-Reply-To: <1353679090-27892-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Fri, 23 Nov 2012 15:58:10 +0200

> This patch changes tun_get_iff() prototype to return void as it never fails.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
