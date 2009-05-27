From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use netdev stats in b44, sundance, via-rhine and
 via-velocity
Date: Wed, 27 May 2009 15:50:11 -0700 (PDT)
Message-ID: <20090527.155011.30414070.davem@davemloft.net>
References: <4A1DA3EA.4030304@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56737
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756615AbZE0WuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 18:50:12 -0400
In-Reply-To: <4A1DA3EA.4030304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 May 2009 22:34:50 +0200

> Use struct net_device_stats provided in struct net_device instead of
> private ones.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6
