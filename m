From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net: smsc911x: switch to new dev_pm_ops
Date: Thu, 06 Aug 2009 13:26:04 -0700 (PDT)
Message-ID: <20090806.132604.241009415.davem@davemloft.net>
References: <20090805.202922.241102337.davem@davemloft.net>
	<OF06D1E485.71250FEA-ON8025760A.003F9572-8025760A.00415798@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@caiaq.de, linux-kernel@vger.kernel.org,
	linux-pm@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, Ian.Saturley@smsc.com
To: Steve.Glendinning@smsc.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <OF06D1E485.71250FEA-ON8025760A.003F9572-8025760A.00415798@smsc.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steve.Glendinning@smsc.com
Date: Thu, 6 Aug 2009 12:53:45 +0100

> David Miller <davem@davemloft.net> wrote on 06/08/2009 04:29:22:
> 
>> From: Daniel Mack <daniel@caiaq.de>
>> Date: Wed,  5 Aug 2009 20:29:31 +0200
>> 
>> > Hibernation is unsupported for now, which meets the actual
>> > implementation in the driver. For free/thaw, the chip's D2 state 
> should
>> > be entered.
>> > 
>> > Signed-off-by: Daniel Mack <daniel@caiaq.de>
>> 
>> Steve, if it looks good to you I can toss this into net-next-2.6
>> 
>> Just let me know.
> 
> Looks fine.  Compiles ok and doesn't actually change any PM 
> implementation.
> 
> Acked-by: <steve.glendinning@smsc.com>

Applied, thanks everyone.
