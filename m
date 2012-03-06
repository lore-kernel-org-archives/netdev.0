From: David Miller <davem@davemloft.net>
Subject: Re: tg3: Fix to use multi queue BQL interfaces
Date: Tue, 06 Mar 2012 01:20:18 -0500 (EST)
Message-ID: <20120306.012018.1047153868474396421.davem@davemloft.net>
References: <alpine.DEB.2.00.1203052147540.19396@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, cl@gentwo.org,
	mcarlson@broadcom.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60026 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930Ab2CFGU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 01:20:28 -0500
In-Reply-To: <alpine.DEB.2.00.1203052147540.19396@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 5 Mar 2012 21:53:50 -0800 (PST)

> Fix tg3 to use BQL multi queue related netdev interfaces since the
> device supports multi queue.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, thanks.
