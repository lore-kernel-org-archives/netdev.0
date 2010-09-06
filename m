From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] r8169: fix rx checksum offload
Date: Sun, 05 Sep 2010 20:04:17 -0700 (PDT)
Message-ID: <20100905.200417.193698196.davem@davemloft.net>
References: <1283716996.3402.342.camel@edumazet-laptop>
	<1283719501.3402.393.camel@edumazet-laptop>
	<20100905222956.GA14472@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	nhorman@tuxdriver.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59816
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754563Ab0IFDEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Sep 2010 23:04:00 -0400
In-Reply-To: <20100905222956.GA14472@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Mon, 6 Sep 2010 00:29:56 +0200

> Eric Dumazet <eric.dumazet@gmail.com> :
> [...]
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>> v2: reuse 'status' variable
> 
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Applied to net-next-2.6, thanks!
