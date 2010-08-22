From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] atl1c: use net_device_stats from struct
 net_device
Date: Sun, 22 Aug 2010 00:09:31 -0700 (PDT)
Message-ID: <20100822.000931.183032685.davem@davemloft.net>
References: <1282308916.2484.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jie.Yang@atheros.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37923
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751324Ab0HVHJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 03:09:14 -0400
In-Reply-To: <1282308916.2484.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Aug 2010 14:55:16 +0200

> struct net_device has its own struct net_device_stats member, so use
> this one instead of a private copy in the atl1c_adapter struct.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
