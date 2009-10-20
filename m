From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] af_packet: mc_drop/flush_mclist changes
Date: Tue, 20 Oct 2009 01:08:01 -0700 (PDT)
Message-ID: <20091020.010801.102497661.davem@davemloft.net>
References: <4AD8A195.3040902@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59691
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751112AbZJTIHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 04:07:38 -0400
In-Reply-To: <4AD8A195.3040902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Oct 2009 18:38:46 +0200

> We hold RTNL, we can use __dev_get_by_index() instead of dev_get_by_index()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
