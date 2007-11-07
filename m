From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Rename "virtual ethernet device" to "virtual ethernet
 pair device".
Date: Tue, 06 Nov 2007 19:19:06 -0800 (PST)
Message-ID: <20071106.191906.127144742.davem@davemloft.net>
References: <200711071409.01000.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@openvz.org, ebiederm@xmission.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40844
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754412AbXKGDTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 22:19:07 -0500
In-Reply-To: <200711071409.01000.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed, 7 Nov 2007 14:09:00 +1100

> There are already iSeries and pSeries virtual ethernet drivers called
> veth; calling a local tunnel device "veth" is confusing.
> 
> I didn't rename the module nor the header, to avoid breaking
> documentation and userspace programs respectively.  But I'd really
> like to.  It'd also be nice to mention "containers" somewhere in the
> help text (I'm assuming that's what it's for?).
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

We had a lengthy discussion about the name on netdev.  I'm sorry that
you missed it, and are bringing this back up again so that we have to
discuss it once more.

If anything, the veth naming makes more sense than the IBM device
cases.

And that's why I decreed that last time this came up that the naming
for veth was just fine.
