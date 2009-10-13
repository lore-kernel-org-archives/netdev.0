From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/hamradio: fix test in receive()
Date: Tue, 13 Oct 2009 03:47:41 -0700 (PDT)
Message-ID: <20091013.034741.260342382.davem@davemloft.net>
References: <4ACB27E8.8060401@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49908
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759460AbZJMKrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 06:47:45 -0400
In-Reply-To: <4ACB27E8.8060401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Tue, 06 Oct 2009 13:20:08 +0200

> The negation makes it a bool before the comparison and hence it
> will never evaluate to true.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied to net-next-2.6, thanks.
