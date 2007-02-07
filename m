From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: handle out of memory errors
Date: Wed, 07 Feb 2007 00:11:23 -0800 (PST)
Message-ID: <20070207.001123.123164404.davem@davemloft.net>
References: <20061219085509.GK4049@APFDCB5C>
	<20061219224422.GB4274@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akinobu.mita@gmail.com, netdev@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48183
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965680AbXBGILY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 03:11:24 -0500
In-Reply-To: <20061219224422.GB4274@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Wed, 20 Dec 2006 00:44:22 +0200

> On Tue, Dec 19, 2006 at 05:55:09PM +0900, Akinobu Mita wrote:
> > This patch checks return value of memory allocation functions
> > for irda subsystem and fixes memory leaks in error cases.
> > 
> > Cc: Samuel Ortiz <samuel@sortiz.org>
> > Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> That looks correct, thanks for the patch.
> 
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Applied, thank you.
