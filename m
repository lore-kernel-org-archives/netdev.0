From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] greth: fall through to common return statement on error
Date: Fri, 26 Feb 2010 04:20:18 -0800 (PST)
Message-ID: <20100226.042018.268178796.davem@davemloft.net>
References: <20100225235019.GA26133@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com, jpirko@redhat.com,
	kirjanov@gmail.com
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48561
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935974Ab0BZMUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 07:20:00 -0500
In-Reply-To: <20100225235019.GA26133@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Fri, 26 Feb 2010 10:50:19 +1100

> There doesn't seem to be any reason to explicitly return
> NETDEV_TX_OK as err is set to NETDEV_TX_OK in all cases that
> reach this point.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>

Looks fine, applied.
