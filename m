From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add init-regs for of_phy support
Date: Mon, 17 Feb 2014 14:11:41 -0500 (EST)
Message-ID: <20140217.141141.1113256967002583742.davem@davemloft.net>
References: <CAGVrzcYbw5xLj-gwcup5i0gBdKDDGdyy5wAaEBp7m2E7f2bytg@mail.gmail.com>
	<53024A62.4050208@codethink.co.uk>
	<20140217180415.GD19308@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben.dooks@codethink.co.uk, f.fainelli@gmail.com,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-sh@vger.kernel.org
To: mark.rutland@arm.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20140217180415.GD19308@e106331-lin.cambridge.arm.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Rutland <mark.rutland@arm.com>
Date: Mon, 17 Feb 2014 18:04:15 +0000

> If you update the DTs to describe the hardware to the kernel, then the
> kernel can later be updated to handle specific PHYs better. That cannot
> happen if you try to hide information from the kernel by giving it a
> list of arbitrary magic numbers.
> 
> Drivers are the place such things should go. The DT is not a place for
> shoddy bytecode.

+1
