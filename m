From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] netdev_ops
Date: Wed, 09 Jul 2003 11:24:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0C5DE3.7000506@candelatech.com>
References: <20030708163042.GL23597@parcelfarce.linux.theplanet.co.uk> <3F0B2D30.4020102@candelatech.com> <20030708212551.GL1939@parcelfarce.linux.theplanet.co.uk> <20030708.150835.78728697.davem@redhat.com> <20030709161520.GW1939@parcelfarce.linux.theplanet.co.uk> <3F0C4CA8.7090502@candelatech.com> <20030709181459.GE15293@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matthew Wilcox <willy@debian.org>, netdev@oss.sgi.com,
   "David S. Miller" <davem@redhat.com>,
   Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030709181459.GE15293@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> On Wed, Jul 09, 2003 at 10:11:04AM -0700, Ben Greear wrote:
> 
>>Also, for the strings (labels) passed back to user space, is there any
>>documentation for suggested values for these strings?  Even though we
>>can't be completely type-safe, if there were suggested values in
>>a comment in the code, it could help a great deal for any code trying to
>>parse them for multiple different drivers/nics.
> 
> 
> The strings represent NIC-specific attributes.

Yes, but surely there is some comonality?  I'm not asking for something
set in stone, but just some general guidelines.  However, I don't feel
too strongly about this, so if it is not worth the time/effort, then
I'll still be happy :)

Ben

> 
> 	Jeff
> 
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
