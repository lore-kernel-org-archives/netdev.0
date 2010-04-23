From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Fri, 23 Apr 2010 00:11:03 -0700 (PDT)
Message-ID: <20100423.001103.233093999.davem@davemloft.net>
References: <alpine.DEB.1.00.1004222249400.27016@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50717
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756184Ab0DWHK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 03:10:58 -0400
In-Reply-To: <alpine.DEB.1.00.1004222249400.27016@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 22 Apr 2010 22:54:16 -0700 (PDT)

> Add support to bnx2x to extract Toeplitz hash out of the receive descriptor
> for use in skb->rxhash.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Sweeeeet.

Applied, thanks Tom.
