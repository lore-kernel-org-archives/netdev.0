From: Ben Shelton <ben.shelton@ni.com>
Subject: Re: [PATCH] usb: plusb: Add support for National Instruments
 host-to-host cable
Date: Fri, 27 Feb 2015 15:26:32 -0600
Message-ID: <20150227212632.GA11789@bshelton-desktop>
References: <1424116026-27869-1-git-send-email-ben.shelton@ni.com>
 <20150220.151417.1734124571561269613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150220.151417.1734124571561269613.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/20, David Miller wrote:
> From: Ben Shelton <ben.shelton@ni.com>
> Date: Mon, 16 Feb 2015 13:47:06 -0600
> 
> > The National Instruments USB Host-to-Host Cable is based on the Prolific
> > PL-25A1 chipset.  Add its VID/PID so the plusb driver will recognize it.
> > 
> > Signed-off-by: Ben Shelton <ben.shelton@ni.com>
> 
> Applied, thanks.

Hi David,

Is this something you think would go into stable as well?

Thanks,
Ben
