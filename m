From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 22 Sep 2004 15:04:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922150425.78839350.davem@davemloft.net>
References: <20040920063012.GL2825@krispykreme>
	<20040920203021.GD4242@wotan.suse.de>
	<20040921155835.18aee381.davem@davemloft.net>
	<20040922140000.GD27432@wotan.suse.de>
	<20040922111209.7887df53.davem@davemloft.net>
	<20040922195515.GA2619@wotan.suse.de>
	<4151DB6C.8050906@us.ibm.com>
	<20040922133011.5885640b.davem@davemloft.net>
	<20040922215657.GB2619@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, ak@suse.de, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040922215657.GB2619@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2004 23:56:57 +0200
Andi Kleen <ak@suse.de> wrote:

> I suspect with a slow bus you can also see advantages
> on 1Gb/s.

Yes, that's true.

I can keep a gigabit line full on my slow 350MHZ
sparc64 boxes except when the card is in a
33Mhz/32-bit PCI slot.
