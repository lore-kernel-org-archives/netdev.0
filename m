From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] - in.h - IP4_ADDR
Date: Mon, 12 Nov 2007 21:28:14 -0800 (PST)
Message-ID: <20071112.212814.130544552.davem@davemloft.net>
References: <1194837570.9407.29.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fred.l.templin@boeing.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59313
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752733AbXKMF2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:28:14 -0500
In-Reply-To: <1194837570.9407.29.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 11 Nov 2007 19:19:30 -0800

> Add inline functions to in.h that make the IP4 address tests
> a bit easier to read and also add some type safety.
> 
> gcc optimizes IP4_ADDR to a constant (O2 or Os)
> 
> Signed-off-by: Joe Perches <joe@perches.com

I have no problems with this, but I'd like to add it along
with subsequent patches that use the new routines and
also I'd like to defer this to net-2.6.25 so please resubmit
this later.

Thanks!
