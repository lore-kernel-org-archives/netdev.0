From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add USB PID for new MOSCHIP USB ethernet
 controller MCS7832 variant
Date: Mon, 20 Dec 2010 10:39:09 -0800 (PST)
Message-ID: <20101220.103909.112598083.davem@davemloft.net>
References: <20101130200737.GA5185@rhlx01.hs-esslingen.de>
	<20101219154257.GA29086@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, dhollis@davehollis.com, pchang23@sbcglobal.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: andi@lisas.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101219154257.GA29086@rhlx01.hs-esslingen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreas Mohr <andi@lisas.de>
Date: Sun, 19 Dec 2010 16:42:57 +0100

> Due to active notification of the new MCS7832 version by the manufacturer
> (Mr. Milton; thanks!) -- quote: "functionality same as MCS7830",
> I'm now submitting this patch (on -rc6), intended for networking.git and -stable.
> 
> - add MCS7832 USB PID to be able to support this new device variant, too
> - add related descriptions
> 
> Signed-off-by: Andreas Mohr <andi@lisas.de>

Applied.
