From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usb: plusb: Add support for National Instruments
 host-to-host cable
Date: Fri, 27 Feb 2015 17:35:38 -0500 (EST)
Message-ID: <20150227.173538.507712773812639200.davem@davemloft.net>
References: <1424116026-27869-1-git-send-email-ben.shelton@ni.com>
	<20150220.151417.1734124571561269613.davem@davemloft.net>
	<20150227212632.GA11789@bshelton-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ben.shelton@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150227212632.GA11789@bshelton-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Shelton <ben.shelton@ni.com>
Date: Fri, 27 Feb 2015 15:26:32 -0600

> On 02/20, David Miller wrote:
>> From: Ben Shelton <ben.shelton@ni.com>
>> Date: Mon, 16 Feb 2015 13:47:06 -0600
>> 
>> > The National Instruments USB Host-to-Host Cable is based on the Prolific
>> > PL-25A1 chipset.  Add its VID/PID so the plusb driver will recognize it.
>> > 
>> > Signed-off-by: Ben Shelton <ben.shelton@ni.com>
>> 
>> Applied, thanks.
> 
> Hi David,
> 
> Is this something you think would go into stable as well?

I'm ambivalent.
