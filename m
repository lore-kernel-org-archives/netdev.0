From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ifdef NET_TX_SOFTIRQ, NET_RX_SOFTIRQ
Date: Thu, 20 Nov 2008 21:02:22 -0800 (PST)
Message-ID: <20081120.210222.193697281.davem@davemloft.net>
References: <20081121045859.GA5625@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33748
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750788AbYKUFCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 00:02:22 -0500
In-Reply-To: <20081121045859.GA5625@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 21 Nov 2008 07:58:59 +0300

> Now that number of softirqs actually matters (see NR_SOFTIRQS), it makes
> sense to not add networking ones when not needed.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

I'd rather not do this for now.

Thanks for the patch, though.
