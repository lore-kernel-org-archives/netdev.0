From: Ben Greear <greearb@candelatech.com>
Subject: Re: cheap 4-port tulip-based cards available
Date: Sat, 19 Oct 2002 14:32:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB1CF5A.9080701@candelatech.com>
References: <slrnaqpajf.2ph.lunz@stoli.localnet> <3DB1C96B.4070505@candelatech.com> <20021019141417.A11659@synapse.neuralscape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Karen Shaeffer <shaeffer@neuralscape.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Karen Shaeffer wrote:
> On Sat, Oct 19, 2002 at 02:06:51PM -0700, Ben Greear wrote:
> 
>>>http://www.softwareandstuff.com/h_comp_inet4.html
>>>
>>>The site says almost nothing about the cards, but on a tip from a
>>>coworker I bought one the last time this site had them for sale, and
>>>have been extremely happy with it. lspci shows:
>>
>>I just got mine, and ordered a bunch more...
>>
>>These are the Phobos p430 NICs.  I have extensively benchmarked 2
>>of those NICs that I got as eval copies, and they perform as good
>>as or better than the 570tx, using the standard tulip driver.
> 
> 
> I'm just curious. What do you do with a bunch of those cards? Do you put
> them in a PC and make a switch out of it?

I make traffic generators out of them (www.candelatech.com)

They are also good for firewalls and routers, as well as more
exotic network devices.  Using linux for a switch does not make so
much sense these days when you can buy a 16 port switch for under $100,
but with bridging code it can be done.

Ben

> 
> cheers,
> Karen


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
