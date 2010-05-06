From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: Fix check to get RX hash
Date: Thu, 06 May 2010 00:14:07 -0700 (PDT)
Message-ID: <20100506.001407.70195021.davem@davemloft.net>
References: <alpine.DEB.1.00.1005052054590.27018@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59528
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753097Ab0EFHOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:14:00 -0400
In-Reply-To: <alpine.DEB.1.00.1005052054590.27018@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 5 May 2010 20:57:16 -0700 (PDT)

> Flag used in check to get rxhash out of the descriptor is incorrect one.
> Fix to use the proper features flag.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied.
