From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [bonding][2/3] Synchronizing 2.4-2.6
Date: Thu, 28 Aug 2003 12:02:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F4E27A2.9060204@pobox.com>
References: <E791C176A6139242A988ABA8B3D9B38A014C94E5@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Hen, Shmulik" <shmulik.hen@intel.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A014C94E5@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hen, Shmulik wrote:
>>-----Original Message-----
>>From: Jeff Garzik [mailto:jgarzik@pobox.com]
>>Sent: Thursday, August 28, 2003 12:52 AM
>>To: Hen, Shmulik
>>Cc: bonding-devel@lists.sourceforge.net; netdev@oss.sgi.com
>>Subject: Re: [bonding][2/3] Synchronizing 2.4-2.6
>>
>>
>>Shmulik Hen wrote:
>>
>>>This is set 2 that merges parts of Jay Vosburgh's experimental
>>>propagation stuff from 5/22 with all the fixes/enhancements
>>>we've developed according to the RFC published on bond-devel
>>>list on 6/2.
>>>
>>>Applies on 2.4.22. Assumes patch set 1 was already applied.
>>
>>
>>As Jay mentioned he had approved through the end of set 2, and set 2 
>>looks good to me, I applied all 8 patches to 2.4.
>>
> 
> 
> Does that mean patch set 2 was also applied ?

Yes.


>>Let's now take an operational pause in 2.4, and get 2.6 back 
>>into sync. 
>>  Would some hearty bonding team member(s) be willing to do that?
>>
> 
> 
> After patch set 1, It should be as easy as just copying all the
> bonding related files from 2.4 to 2.6. I guess I can do that on
> Sunday if someone hasn't already done it before.

I had hoped to preserve the revision history.  Simply copying the files 
over does not do that :(

What I mean by preserving revision history is, changes should be 
submitted to 2.6 in the same granularity as they were to 2.4...

	Jeff
