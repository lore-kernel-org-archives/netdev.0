From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 09/10] bnx2x: Added FW GRO bridging support
Date: Tue, 15 Jan 2013 15:09:14 -0500 (EST)
Message-ID: <20130115.150914.729025796621947521.davem@davemloft.net>
References: <50F50537.3030608@broadcom.com>
	<1358260752.8744.5677.camel@edumazet-glaptop>
	<50F56178.8000502@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	eilong@broadcom.com, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637Ab3AOUJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 15:09:16 -0500
In-Reply-To: <50F56178.8000502@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Tue, 15 Jan 2013 16:02:32 +0200

> Considering Eric's response, following with option (1) or (2) seems like the
> right way to go.
> 
> Do you want a new patch series which will include a fix for this,
> or will you accept a later fix that sets the gso_segs correctly?
> 
> (considering this issue is not introduced in this patch,
> merely isn't being solved by it)

I've merged your patch series as-is to net-next, please work on fixing
the problems Eric has pointed out.

Thanks.
