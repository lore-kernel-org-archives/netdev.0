From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] doc: make the description of how tcp_ecn
 works more explicit and clear
Date: Thu, 29 Nov 2012 13:16:27 -0500 (EST)
Message-ID: <20121129.131627.987805831377793894.davem@davemloft.net>
References: <20121128195310.C438D2900459@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: raj@tardy.usa.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894Ab2K2SQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:16:28 -0500
In-Reply-To: <20121128195310.C438D2900459@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: raj@tardy.usa.hp.com (Rick Jones)
Date: Wed, 28 Nov 2012 11:53:10 -0800 (PST)

> From: Rick Jones <rick.jones2@hp.com>
> 
> Make the description of how tcp_ecn works a bit more explicit and clear.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

Applied, thanks Rick.

I think we should change the default to one, to be honest.  I thought
that's what we were doing by now...

'2' made sense 10 years ago, but it doesn't really today.
