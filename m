From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: Re: [PATCH net-next v3 01/13] phy: add sgmii and 10gkr modes to the
 phy_mode enum
Date: Tue, 29 Aug 2017 17:51:52 +0530
Message-ID: <36a628d5-bc3b-e017-0f02-d1a77cfd5aab@ti.com>
References: <20170828145725.2539-1-antoine.tenart@free-electrons.com>
 <20170828145725.2539-2-antoine.tenart@free-electrons.com>
 <4c66e79f-d385-3cf5-6f24-2a4aec9fb3b4@ti.com> <20170829112717.GC31552@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <andrew@lunn.ch>, <jason@lakedaemon.net>,
        <sebastian.hesselbarth@gmail.com>,
        <gregory.clement@free-electrons.com>,
        <thomas.petazzoni@free-electrons.com>, <nadavh@marvell.com>,
        <linux@armlinux.org.uk>, <linux-kernel@vger.kernel.org>,
        <mw@semihalf.com>, <stefanc@marvell.com>,
        <miquel.raynal@free-electrons.com>, <netdev@vger.kernel.org>
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170829112717.GC31552@kwain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tuesday 29 August 2017 04:57 PM, Antoine Tenart wrote:
> Hi Kishon,
> 
> On Tue, Aug 29, 2017 at 04:08:29PM +0530, Kishon Vijay Abraham I wrote:
>> On Monday 28 August 2017 08:27 PM, Antoine Tenart wrote:
>>> This patch adds more generic PHY modes to the phy_mode enum, to
>>> allow configuring generic PHYs to the SGMII and/or the 10GKR mode
>>> by using the set_mode callback.
>>>
>>> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
>>
>> Acked-by: Kishon Vijay Abraham I <kishon@ti.com>
> 
> Does this means the generic PHY patches of this series can go through
> the net-next tree (once all the comments are taken into account)?

yeah.. I'm already done with my pull request for 4.14 to Greg KH. As long as it
doesn't cause any conflicts to Linus, it should be okay to merge it in net-next.

Thanks
Kishon
