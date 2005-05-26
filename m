From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH linux-2.6.12-rc4-mm1] ethtool: Add NETIF_F_HW_CSUM
 support
Date: Thu, 26 May 2005 16:00:04 -0700 (PDT)
Message-ID: <20050526.160004.18577501.davem@davemloft.net>
References: <20050523210757.GB5910@us.ibm.com>
	<20050523.142009.74748115.davem@davemloft.net>
	<20050523145321.49899042@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20050523145321.49899042@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 23 May 2005 14:53:21 -0700

> This patch makes perfect sense because it allows for common code to be
> used by device drivers in their ethtool_ops. So this is the logical way to handle
> this.

You're right, of course.  I've applied the patch.

Thanks.
