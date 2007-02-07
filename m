From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irlan: handle out of memory errors
Date: Wed, 07 Feb 2007 00:12:26 -0800 (PST)
Message-ID: <20070207.001226.63510892.davem@davemloft.net>
References: <20061219085601.GL4049@APFDCB5C>
	<20061219224726.GC4274@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akinobu.mita@gmail.com, netdev@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48188
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965679AbXBGIM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 03:12:26 -0500
In-Reply-To: <20061219224726.GC4274@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Wed, 20 Dec 2006 00:47:26 +0200

> On Tue, Dec 19, 2006 at 05:56:01PM +0900, Akinobu Mita wrote:
> > This patch checks return values:
> > 
> > - irlmp_register_client()
> > - irlmp_register_service()
> > - irlan_open()
> > 
> > Cc: Samuel Ortiz <samuel@sortiz.org>
> > Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> This one seems correct as well, thanks again.
> 
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Also applied, thanks a lot.
