From: Ben Greear <greearb@candelatech.com>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Fri, 03 Jan 2003 17:45:31 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E163CBB.30206@candelatech.com>
References: <Pine.LNX.4.44.0301032029540.29812-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, jamal <hadi@cyberus.ca>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
In-Reply-To: <Pine.LNX.4.44.0301032029540.29812-100000@beohost.scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Donald Becker wrote:

> It was
>   "If you need this capability for a RESEARCH PROJECT, you can buy this
>   specific board and thus not need to modify the kernel or device
>   driver. "
> 
> You can also find a few people that want to receive specific corrupted
> packets, change the meaning of LEDs on a NIC, and do many other strange
> things.  But we don't need a defined kernel interface for each one.

Just out of curiosity, what is the suggested manner for adding such
back-door hacks as this?  Maybe in a proc file system that the driver
implements?  It would be neat to see various driver-specific features
like this be implemented, and it would be even nicer if they followed
at least some general guideline for how to interface with the rest of
the world...

> 
> Improvement is what you can eliminate or simplify, not adding complexity.

Exposing new features can also be an improvement, though one does
not imply the other ;)

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
