From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH rfc] atm/iphase : removal of PCI space dereferences.
Date: Fri, 29 Apr 2011 13:54:49 -0700 (PDT)
Message-ID: <20110429.135449.212692718.davem@davemloft.net>
References: <20110427203805.GI19708@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38159
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758846Ab1D2UzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 16:55:22 -0400
In-Reply-To: <20110427203805.GI19708@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 27 Apr 2011 22:38:05 +0200

> Mostly PHY access and a few (ugly) debug statements for DMA control.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
> 
>  Really RFCish. I ought to be able to give it some trivial crash testing.

I like this change, please give it some testing and submit formally.

Thanks!
