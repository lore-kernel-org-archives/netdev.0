From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] DECnet: don't leak uninitialized stack byte
Date: Sun, 28 Nov 2010 11:32:43 -0800 (PST)
Message-ID: <20101128.113243.116388416.davem@davemloft.net>
References: <1290546133.2276.10.camel@dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: drosenberg@vsecurity.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54393
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752077Ab0K1TcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 14:32:17 -0500
In-Reply-To: <1290546133.2276.10.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Tue, 23 Nov 2010 16:02:13 -0500

> A single uninitialized padding byte is leaked to userspace.
> 
> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>

Applied, thanks Dan.
