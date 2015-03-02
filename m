From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usb: plusb: Add support for National Instruments
 host-to-host cable
Date: Mon, 02 Mar 2015 15:26:08 -0500 (EST)
Message-ID: <20150302.152608.2005101977426036416.davem@davemloft.net>
References: <20150227212632.GA11789@bshelton-desktop>
	<20150227.173538.507712773812639200.davem@davemloft.net>
	<20150302160014.GA28172@bshelton-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ben.shelton@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150302160014.GA28172@bshelton-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Shelton <ben.shelton@ni.com>
Date: Mon, 2 Mar 2015 10:00:14 -0600

> On 02/27, David Miller wrote:
>> From: Ben Shelton <ben.shelton@ni.com>
>> Date: Fri, 27 Feb 2015 15:26:32 -0600
>> 
>> > On 02/20, David Miller wrote:
>> >> From: Ben Shelton <ben.shelton@ni.com>
>> >> Date: Mon, 16 Feb 2015 13:47:06 -0600
>> >> 
>> >> > The National Instruments USB Host-to-Host Cable is based on the Prolific
>> >> > PL-25A1 chipset.  Add its VID/PID so the plusb driver will recognize it.
>> >> > 
>> >> > Signed-off-by: Ben Shelton <ben.shelton@ni.com>
>> >> 
>> >> Applied, thanks.
>> > 
>> > Hi David,
>> > 
>> > Is this something you think would go into stable as well?
>> 
>> I'm ambivalent.
> 
> In that case, could you go ahead and apply it to stable as well?

Done.
