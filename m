From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usb: plusb: Add support for National Instruments
 host-to-host cable
Date: Fri, 20 Feb 2015 15:14:17 -0500 (EST)
Message-ID: <20150220.151417.1734124571561269613.davem@davemloft.net>
References: <1424116026-27869-1-git-send-email-ben.shelton@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ben.shelton@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424116026-27869-1-git-send-email-ben.shelton@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Shelton <ben.shelton@ni.com>
Date: Mon, 16 Feb 2015 13:47:06 -0600

> The National Instruments USB Host-to-Host Cable is based on the Prolific
> PL-25A1 chipset.  Add its VID/PID so the plusb driver will recognize it.
> 
> Signed-off-by: Ben Shelton <ben.shelton@ni.com>

Applied, thanks.
