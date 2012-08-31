From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] net/xfrm/xfrm_state.c: fix error return code
Date: Fri, 31 Aug 2012 16:28:15 -0400 (EDT)
Message-ID: <20120831.162815.212003559560432706.davem@davemloft.net>
References: <1346258957-7649-1-git-send-email-Julia.Lawall@lip6.fr>
	<1346258957-7649-6-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53332 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754967Ab2HaU2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 16:28:17 -0400
In-Reply-To: <1346258957-7649-6-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Wed, 29 Aug 2012 18:49:15 +0200

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Initialize return variable before exiting on an error path.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
