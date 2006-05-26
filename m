From: Meelis Roos <mroos@linux.ee>
Subject: Re: ipv6 routing broken in 2.6.17-rc3,4
Date: Fri, 26 May 2006 13:44:59 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0605261344340.26383@math.ut.ee>
References: <20060526.104001.96071021.yoshfuji@linux-ipv6.org>
 <20060526.104245.106225873.yoshfuji@linux-ipv6.org>
 <Pine.SOC.4.61.0605261134250.18708@math.ut.ee> <20060526.190856.33048221.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: pekkas@netcore.fi, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:7864 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1751375AbWEZKpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 06:45:16 -0400
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20060526.190856.33048221.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> The unreachable route works now but LAN routing still does not work.
>> Locally generated ICMPv6 packets that should go to LAN interface still
>> go to tun6to4.
>
> Please try this.

This works for both unreachable and LAN routes, thanks!

-- 
Meelis Roos (mroos@linux.ee)
