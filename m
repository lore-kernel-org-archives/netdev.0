From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] ks8851 MAC and eeprom updates
Date: Sat, 26 Nov 2011 14:57:28 -0500 (EST)
Message-ID: <20111126.145728.475483160422235867.davem@davemloft.net>
References: <1321901880-12883-1-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, s-jan@ti.com,
	ben@simtec.co.uk
To: sboyd@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321901880-12883-1-git-send-email-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Boyd <sboyd@codeaurora.org>
Date: Mon, 21 Nov 2011 10:57:55 -0800

> I pulled this patch series off the netdev list[1] when the eeprom
> reading didn't work for my ks8851 and I wanted the mac address to be
> read out at boot. It all seems to work well, so I'm posting it here
> again, slightly cleaned up and simplified, for inclusion.
> 
> Overall it reduces the lines of code and properly supports eeprom
> reading; two things the previous implementation doesn't do.
> 
> This is based off of linux-next-20111025.
> 
> Thanks to Ben Dooks for doing the heavy lifting.
> 
> [1] http://article.gmane.org/gmane.linux.network/159708

I guess I'll apply this series to net-next, I hope the eeprom layer
maintainers don't mind.

Thanks.
