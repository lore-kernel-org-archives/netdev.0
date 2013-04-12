From: Mark Jackson <mpfj-list@mimc.co.uk>
Subject: Re: [PATCH 0/3] Dual EMAC mode implementation of CPSW
Date: Fri, 12 Apr 2013 10:14:49 +0100
Message-ID: <5167D089.3000105@mimc.co.uk>
References: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com> <20130212.161538.1899836892271837177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20130212.161538.1899836892271837177.davem@davemloft.net>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/02/13 21:15, David Miller wrote:
> From: Mugunthan V N <mugunthanvnm@ti.com>
> Date: Tue, 12 Feb 2013 01:22:17 +0530
> 
>> This patch series implements Dual EMAC mode implementation of CPSW
>> which acts as two standalone EMAC by segregating the switch using VIDs
>> and port VLAN
>>
>> Mugunthan V N (3):
>>   driver: net: ethernet: davinci_cpdma: add support for directed packet
>>     and source port detection
>>   driver: net: ethernet: cpsw: make cpts as pointer
>>   driver: net: ethernet: cpsw: dual emac interface implementation
> 
> Series applied.

I can see that this series is now in the mainline kernel, but can anyone
give me some pointers on how to use it ?

First, I'd like to check that it's achieving what I think it does ...
namely to be able to access both eth0 and eth1 as separate Ethernet ports ?

If this assumption is correct, can anyone guide me as to how to setup my
dts file to allow the kernel to see both ports ?

If have been trying to get it going (see my posting [1]), but to no avail.

Any help would be greatly appreciated !!

[1] http://www.spinics.net/lists/linux-omap/msg89920.html

Regards
Mark JACKSON
