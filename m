From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Redirect-Device
Date: Thu, 31 Mar 2005 15:35:22 -0800
Message-ID: <424C893A.20601@candelatech.com>
References: <424C6089.1080507@candelatech.com>	 <1112303627.1073.71.camel@jzny.localdomain>	 <424C6B10.6030200@candelatech.com>	 <1112306031.1073.109.camel@jzny.localdomain>	 <424C7813.4000101@candelatech.com> <1112311240.1096.13.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1112311240.1096.13.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

> One thing you probably havent understood is that all the action stuff
> that happens on ingress happens before dev.c pkt receive.

Could you point me to where this is, or give me something to
search for?  I'm curious how/where it does the hook, and if I
understand that better, maybe I can start thinking about how
to make use of it for future hacks...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
