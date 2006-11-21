From: David Miller <davem@davemloft.net>
Subject: Re: [-mm patch] make net/core/skbuff.c:skb_over_panic() static
Date: Mon, 20 Nov 2006 19:55:56 -0500 (EST)
Message-ID: <20061120.195556.23029046.davem@davemloft.net>
References: <20061114014125.dd315fff.akpm@osdl.org>
	<20061117170205.GE31879@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:8613 "EHLO localhost")
	by vger.kernel.org with ESMTP id S1030620AbWKUAz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 19:55:56 -0500
To: bunk@stusta.de
In-Reply-To: <20061117170205.GE31879@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Fri, 17 Nov 2006 18:02:05 +0100

> skb_over_panic() can now become static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied to net-2.6.20, thanks Adrian.
