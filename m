From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/ixgbe/ixgbe_common.c: use %pM to show MAC
 address
Date: Thu, 07 Jan 2010 01:18:50 -0800 (PST)
Message-ID: <20100107.011850.176718572.davem@davemloft.net>
References: <201001050956.53199.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: hartleys@visionengravers.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933064Ab0AGJVQ@vger.kernel.org>
In-Reply-To: <201001050956.53199.hartleys@visionengravers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: H Hartley Sweeten <hartleys@visionengravers.com>
Date: Tue, 5 Jan 2010 09:56:52 -0700

> Use the %pM kernel extension to display the MAC address.
> 
> The only difference in the output is that the MAC address is
> shown in the usual colon-separated hex notation.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

Applied.
