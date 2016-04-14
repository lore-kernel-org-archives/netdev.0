From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qdisc: constify meta_type_ops structures
Date: Thu, 14 Apr 2016 00:35:53 -0400 (EDT)
Message-ID: <20160414.003553.1230847109093798091.davem@davemloft.net>
References: <1460191762-10986-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274AbcDNEfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 00:35:55 -0400
In-Reply-To: <1460191762-10986-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sat,  9 Apr 2016 10:49:22 +0200

> The meta_type_ops structures are never modified, so declare them as const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied, thank you.
