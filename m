From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sit: fix percpu stats accounting
Date: Wed, 29 Sep 2010 13:27:10 -0700 (PDT)
Message-ID: <20100929.132710.70206138.davem@davemloft.net>
References: <1285676278.3154.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34968
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755716Ab0I2U0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 16:26:49 -0400
In-Reply-To: <1285676278.3154.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 28 Sep 2010 14:17:58 +0200

> commit 15fc1f7056ebd (sit: percpu stats accounting) forgot the fallback
> tunnel case (sit0), and can crash pretty fast.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
