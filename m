From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 03/12] net-next: mediatek: add embedded switch
 driver (ESW)
Date: Fri, 26 Feb 2016 12:43:13 -0500 (EST)
Message-ID: <20160226.124313.718457444189293093.davem@davemloft.net>
References: <1456496504-50429-4-git-send-email-blogic@openwrt.org>
	<20160226151813.GD12022@lunn.ch>
	<56D07C82.2040204@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, blogic@openwrt.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
	matthias.bgg@gmail.com, steven.liu@mediatek.com,
	Carlos.Huang@mediatek.com, Fred.Chang@mediatek.com
To: nbd@openwrt.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56D07C82.2040204@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Felix Fietkau <nbd@openwrt.org>
Date: Fri, 26 Feb 2016 17:25:38 +0100

> In my opinion, leaving this part out does not make much sense and
> neither does deferring the entire patch series until we have a
> switchdev/DSA capable driver. This is just a starting point, which will
> be turned into a proper driver with the right APIs later.

I disagree, and we want people to concentrate on writing proper
switchdev/DSA drivers.

People like Andrew have offered to help in any way possible to make
this as easy as possible, so please take this seriously.

I would have accepted your arguments a year ago when we didn't have
the right infrastructure, but now we do and there is no real excuse
to submit partial or bastardized drivers for these kinds of hardware
anymore

Thanks in advance for your understanding, and I'm plan to stand
very firm on this.
