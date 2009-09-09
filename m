From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend] s2io: Remove unnecessary casts
Date: Wed, 09 Sep 2009 03:40:57 -0700 (PDT)
Message-ID: <20090909.034057.58038960.davem@davemloft.net>
References: <1252384015.6396.11.camel@dbueso-pc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dave@gnu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51856
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752689AbZIIKkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 06:40:41 -0400
In-Reply-To: <1252384015.6396.11.camel@dbueso-pc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Davidlohr Bueso <dave@gnu.org>
Date: Tue, 08 Sep 2009 00:26:55 -0400

> Hi David,
> 
> Don't know why my email client corrupted the patch, anyways, here it is without white spaces.
> 
> No need to cast kmalloc.
> 
> Thanks,
> Davidlohr
> 
> 
> Signed-off-by: Davidlohr Bueso <dave@gnu.org>

Since you last submitted this patch a large series of cleanup
patches were added to this driver in the net-next-2.6 tree
and as a result your patch no longer applies properly.

You'll need to respin these changes and make sure they
apply cleanly to net-next-2.6

Thanks.
