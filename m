From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] doc: Tighten-up and clarify description of
 tcp_fin_timeout
Date: Mon, 10 Dec 2012 17:14:44 -0500 (EST)
Message-ID: <20121210.171444.1204644598241869819.davem@davemloft.net>
References: <20121210213300.9D6BB29003EA@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: raj@tardy.usa.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60652 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472Ab2LJWOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 17:14:45 -0500
In-Reply-To: <20121210213300.9D6BB29003EA@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: raj@tardy.usa.hp.com (Rick Jones)
Date: Mon, 10 Dec 2012 13:33:00 -0800 (PST)

> From: Rick Jones <rick.jones2@hp.com>
> 
> The description for tcp_fin_timeout should be tigher and more clear.
> 
> In addition to being tighter, we should make the spelling of the
> state name consistent with what utilities report, remove the now
> dated reference to 2.2 and put the default in the consistent place.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

Applied, thanks Rick.
