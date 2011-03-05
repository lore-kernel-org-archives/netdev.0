From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: tun routing is broken
Date: Sat, 05 Mar 2011 09:26:29 +0100
Message-ID: <4D71F3B5.7080803@suse.cz>
References: <20110304.010603.104076956.davem@davemloft.net>	<4D70B2DC.2000005@gmail.com>	<4D71EE86.6030309@suse.cz> <20110305.001022.183044112.davem@davemloft.net> <4D71F194.9010402@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, mm-commits@vger.kernel.org,
	netdev@vger.kernel.org, maxk@qualcomm.com
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D71F194.9010402@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/05/2011 09:17 AM, Jiri Slaby wrote:
>> ipv4: Fix __ip_dev_find() to use ifa_local instead of ifa_address.
> 
> It would be great to have a References: tag or better changelog. Then I
> would give the commit a shot. The way it is I ignored it when looking at
> next/master inside net/ipv4/ changes for commits to test.
> 
> Going to boot with this change.

Yes, it works.

thanks,
-- 
js
suse labs
