From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] tcp: keepalive cleanups
Date: Fri, 28 Aug 2009 23:49:01 -0700 (PDT)
Message-ID: <20090828.234901.197522496.davem@davemloft.net>
References: <4A967B78.8050409@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58406
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751834AbZH2Gsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 02:48:47 -0400
In-Reply-To: <4A967B78.8050409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 27 Aug 2009 14:26:32 +0200

> Introduce keepalive_probes(tp) helper, and use it, like 
> keepalive_time_when(tp) and keepalive_intvl_when(tp)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
