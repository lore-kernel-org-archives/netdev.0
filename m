From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4: fib_trie remove unused argument
Date: Thu, 10 Apr 2008 03:46:37 -0700 (PDT)
Message-ID: <20080410.034637.231947654.davem@davemloft.net>
References: <20080402215724.4cf5fbf0@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51554
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754605AbYDJKqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 06:46:36 -0400
In-Reply-To: <20080402215724.4cf5fbf0@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 2 Apr 2008 21:57:24 -0700

> The trie pointer is passed down to flush_list and flush_leaf
> but never used.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
