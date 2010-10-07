From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Documentation/networking/ixgbevf.txt: Change file
 permissions to 644
Date: Wed, 06 Oct 2010 18:42:15 -0700 (PDT)
Message-ID: <20101006.184215.35062616.davem@davemloft.net>
References: <1286402990.32241.10.camel@Joe-Laptop>
	<20101006.173353.179919967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	rdunlap@xenotime.net, gregory.v.rose@intel.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49889
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759763Ab0JGBlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 21:41:53 -0400
In-Reply-To: <20101006.173353.179919967.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 06 Oct 2010 17:33:53 -0700 (PDT)

> From: Joe Perches <joe@perches.com>
> Date: Wed, 06 Oct 2010 15:09:50 -0700
> 
>> Signed-off-by: Joe Perches <joe@perches.com>
>> ---
>> diff --git a/Documentation/networking/ixgbevf.txt b/Documentation/networking/ixgbevf.txt
>> old mode 100755
>> new mode 100644
> 
> Applied, thanks.

Actually, only net-next-2.6 needs this and this permission issue will
end up getting fixed transparently when I merge net-2.6 into
net-next-2.6

Which I need to do right now to resolve a conflict anyways.

So I won't actually be applying this patch.
