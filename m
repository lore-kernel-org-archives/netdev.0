From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: Print error value when skb allocation fails
Date: Tue, 02 Jun 2009 00:20:36 -0700 (PDT)
Message-ID: <20090602.002036.230507788.davem@davemloft.net>
References: <1243882073-15335-1-git-send-email-brian.haley@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37983
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753119AbZFBHUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 03:20:36 -0400
In-Reply-To: <1243882073-15335-1-git-send-email-brian.haley@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Mon,  1 Jun 2009 14:47:53 -0400

> Print-out the error value when sock_alloc_send_skb() fails in
> the IPv6 neighbor discovery code - can be useful for debugging.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Applied to net-next-2.6, thanks Brian.
