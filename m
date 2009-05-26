From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1: use netdev->stats
Date: Mon, 25 May 2009 23:48:54 -0700 (PDT)
Message-ID: <20090525.234854.17328577.davem@davemloft.net>
References: <4A1B8F5A.9040908@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36971
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752826AbZEZGsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 02:48:55 -0400
In-Reply-To: <4A1B8F5A.9040908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 May 2009 08:42:34 +0200

> Get rid of private struct net_device_stats in "struct atl1e_adapter",
> and use one provided in struct net_device instead.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
