From: David Miller <davem@davemloft.net>
Subject: Re: [XFRM]: beet: fix worst case header_len calculation
Date: Mon, 09 Apr 2007 11:50:35 -0700 (PDT)
Message-ID: <20070409.115035.18599308.davem@davemloft.net>
References: <461859F3.50303@trash.net>
	<20070409.114840.18284797.davem@davemloft.net>
	<461A8AD7.90607@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44079
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932185AbXDISug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 14:50:36 -0400
In-Reply-To: <461A8AD7.90607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 09 Apr 2007 20:49:59 +0200

> David Miller wrote:
> > Applied, thanks Patrick.
> > 
> > Can you backport this to 2.6.21 for me, if you think we should
> > bother?  Thanks.
> 
> 
> Its merely an optimization, so I don't think we should put it in 2.6.21
> at this point in the release cycle.

Agreed.
