From: Ben Greear <greearb@candelatech.com>
Subject: Re: [ANNOUNCE] NAPI patches for 2.4.19-rc1
Date: Thu, 11 Jul 2002 10:17:24 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D2DBDA4.4090009@candelatech.com>
References: <Pine.LNX.4.44.0207111238570.2498-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, jamal <hadi@cyberus.ca>,
   netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
List-Id: netdev.vger.kernel.org

Donald Becker wrote:

> Very, very few vendor patchs are worth applying.  They sometimes know of
> otherwise undocumented chip bugs, but a lot of the actual code is bad.
> 
> It's not "maintaining" a driver when you just take a vendor modification
> of a driver and assume it's OK.  You have to understand the changes and
> evaluate if they make sense.

I don't know the quality of the patches submitted by dlink, but I do
know that the existing driver in the 2.4.18 kernel absolutely does not
work at all.  So, if there is a hack/patch that makes it work, I consider
that better than completely broken, even if it is ugly.

Of course, the preferred driver would be clean and work with all chipsets,
but those are not easy to find.

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
