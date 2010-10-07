From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Documentation/networking/ixgbevf.txt: Change file
 permissions to 644
Date: Wed, 06 Oct 2010 18:59:27 -0700 (PDT)
Message-ID: <20101006.185927.242117415.davem@davemloft.net>
References: <20101006.173353.179919967.davem@davemloft.net>
	<20101006.184215.35062616.davem@davemloft.net>
	<1286416346.3292.2.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	rdunlap@xenotime.net, gregory.v.rose@intel.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55694
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757586Ab0JGB7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 21:59:07 -0400
In-Reply-To: <1286416346.3292.2.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 06 Oct 2010 18:52:26 -0700

> On Wed, 2010-10-06 at 18:42 -0700, David Miller wrote:
>> So I won't actually be applying this patch.
> 
> No worries, happy it's getting resolved.
> 
> I sent a patch to checkpatch so these could be avoided
> in the future.  Maybe Andy W has a better idea.

GIT would probably be a better place to detect this, even if
it's not on by default I would enable it in my own personal
.gitconfig
