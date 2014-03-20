From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2a 1/2] dt: Document a compatible entry for MDIO
 ethernet Phys
Date: Thu, 20 Mar 2014 17:10:49 -0400 (EDT)
Message-ID: <20140320.171049.532173053790368494.davem@davemloft.net>
References: <1395267324-5788-1-git-send-email-jgunthorpe@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jgunthorpe@obsidianresearch.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395267324-5788-1-git-send-email-jgunthorpe@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Date: Wed, 19 Mar 2014 16:15:23 -0600

> This describes a compatible entry of the form:
>   ethernet-phy-idAAAA,BBBB
> Which is modelled after the PCI structured compatible entry
> (pciVVVV,DDDD.SSSS.ssss.RR)
> 
> If present the OF core will be able to use this information to
> directly create the correct phy without auto probing the bus.
> 
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Acked-by: Rob Herring <robh@kernel.org>
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Applied to net-next.
