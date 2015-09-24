From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mdio-octeon: Add PCI driver binding.
Date: Thu, 24 Sep 2015 16:07:57 -0700 (PDT)
Message-ID: <20150924.160757.907239258265499481.davem@davemloft.net>
References: <56047D15.9080105@caviumnetworks.com>
	<20150924.155004.109163182451628208.davem@davemloft.net>
	<56047F26.9070305@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ddaney.cavm@gmail.com, linux-kernel@vger.kernel.org,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, david.daney@cavium.com
To: ddaney@caviumnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56047F26.9070305@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney@caviumnetworks.com>
Date: Thu, 24 Sep 2015 15:54:30 -0700

> On 09/24/2015 03:50 PM, David Miller wrote:
>> From: David Daney <ddaney@caviumnetworks.com>
>> Date: Thu, 24 Sep 2015 15:45:41 -0700
>>
>>> 2) The OF device tree nodes for PCI devices do not result in the
>>> creation of a platform device.
>>
>> But they are created for the children right?  And that's the one
>> you need them for probing.
>>
>> I'm still not convinced, sorry.
>>
> 
> Let's let this topic rest for a few days.  My original patch was
> defective, so it cannot be merged.  I will sleep on this, try a few
> things and perhaps revisit it if I still think it is advisable.

Ok.
