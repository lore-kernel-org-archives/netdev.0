From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: use RT_TOS after some rt_tos conversions
Date: Sat, 23 Jul 2011 20:05:14 -0700 (PDT)
Message-ID: <20110723.200514.57681165749319604.davem@davemloft.net>
References: <alpine.LFD.2.00.1107231455220.1537@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32996 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832Ab1GXDFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 23:05:23 -0400
In-Reply-To: <alpine.LFD.2.00.1107231455220.1537@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sat, 23 Jul 2011 15:00:41 +0300 (EEST)

> rt_tos was changed to iph->tos but it must be filtered by RT_TOS
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied, thanks Julian.
