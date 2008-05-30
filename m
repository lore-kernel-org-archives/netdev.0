From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] IRDA: Do cleanup for dma
Date: Fri, 30 May 2008 02:44:15 -0700 (PDT)
Message-ID: <20080530.024415.130028472.davem@davemloft.net>
References: <48365CBF.4080502@cn.fujitsu.com>
	<20080529.033442.175635712.davem@davemloft.net>
	<6fe1847af5073e7f50519a2ebc730653@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, jgarzik@pobox.com, netdev@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53679
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752328AbYE3JoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 05:44:19 -0400
In-Reply-To: <6fe1847af5073e7f50519a2ebc730653@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <samuel@sortiz.org>
Date: Sat, 21 Jan 2006 07:07:16 +0100

> 
> Hi Dave,
> 
> On Thu, 29 May 2008 03:34:42 -0700 (PDT), David Miller
> <davem@davemloft.net> wrote:
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
> I'll take it and send it along with my next IrDA patch set.

Oh ok, you got it :-)
