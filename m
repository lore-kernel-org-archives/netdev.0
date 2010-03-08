From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethtool: Use noinline_for_stack
Date: Mon, 08 Mar 2010 12:17:12 -0800 (PST)
Message-ID: <20100308.121712.85419280.davem@davemloft.net>
References: <1268077563.2819.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36413
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755563Ab0CHUQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 15:16:52 -0500
In-Reply-To: <1268077563.2819.61.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 08 Mar 2010 20:46:03 +0100

> Use self documenting noinline_for_stack instead of duplicated comments.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
