From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] IRDA: Do cleanup for dma
Date: Fri, 30 May 2008 02:44:01 -0700 (PDT)
Message-ID: <20080530.024401.193700564.davem@davemloft.net>
References: <48365CBF.4080502@cn.fujitsu.com>
	<20080529.033442.175635712.davem@davemloft.net>
	<483EAF39.1040302@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53674
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750934AbYE3JoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 05:44:07 -0400
In-Reply-To: <483EAF39.1040302@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jgarzik@pobox.com>
Date: Thu, 29 May 2008 09:27:21 -0400

> David Miller wrote:
> > From: Wang Chen <wangchen@cn.fujitsu.com>
> > Date: Fri, 23 May 2008 13:57:19 +0800
> > 
> >> 1. dma should be freed when dma2 request fail.
> >> 2. dma2 should be freed too when device close.
> >>
> >> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> > 
> > Jeff, did you get this or would you like me to pick
> > it up directly?
> 
> I never pick up IRDA stuff.

Great I'll apply it then.
