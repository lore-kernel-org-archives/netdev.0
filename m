From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] Networking: send-to-self [link to non-broken patch this
Date: Fri, 27 Sep 2002 08:53:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D947EF7.2080302@candelatech.com>
References: <200209271546.TAA21299@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> 
>>It will not match the case where the sending socket is bound to interface 3
>>and the listening socket is bound on interface 4, but both sockets have the
>>same source IP and port.  That was what I was trying
>>to do...but I may have not done it quite right :)
> 
> 
> I would say "quite not right". :-)
> 
> Anyway, this is supposed to work without any modifications.

I will run some tests with that part of the code commented out.

Thanks,
Ben

> 
> Alexey
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
