From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] UDPCP Communication Protocol
Date: Thu, 06 Jan 2011 12:17:39 -0800 (PST)
Message-ID: <20110106.121739.258115710.davem@davemloft.net>
References: <1293787785-3834-1-git-send-email-stefani@seibold.net>
	<20110106201100.GA3582@ucw.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefani@seibold.net, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: pavel@ucw.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110106201100.GA3582@ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Machek <pavel@ucw.cz>
Date: Thu, 6 Jan 2011 21:11:00 +0100

> Hi!
> 
>> UDPCP is a communication protocol specified by the Open Base Station
>> Architecture Initiative Special Interest Group (OBSAI SIG). The
>> protocol is based on UDP and is designed to meet the needs of "Mobile
>> Communcation Base Station" internal communications. It is widely used by
>> the major networks infrastructure supplier.
> 
> Why does it need to be in kernel?

To avoid a 40% performance hit which he explained in these threads.
