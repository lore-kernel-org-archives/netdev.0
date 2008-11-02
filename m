From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/2] nets: fix problem of return value
Date: Sat, 01 Nov 2008 21:37:51 -0700 (PDT)
Message-ID: <20081101.213751.06182621.davem@davemloft.net>
References: <20081101101835.GG6556@ubuntu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jianjun@zeuux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46534
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751637AbYKBEiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 00:38:17 -0400
In-Reply-To: <20081101101835.GG6556@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianjun Kong <jianjun@zeuux.org>
Date: Sat, 1 Nov 2008 18:18:35 +0800

> fix problem of return value
> 
> net/unix/af_unix.c: unix_net_init()
> when error appears, it should return 'error', not always return 0.
> 
> Signed-off-by: Jianjun Kong <jianjun@zeuux.org>

Applied, thank you.
