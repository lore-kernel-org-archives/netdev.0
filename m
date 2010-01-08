From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/skfp/skfddi.c: use %pMF to show MAC address
Date: Thu, 07 Jan 2010 16:59:04 -0800 (PST)
Message-ID: <20100107.165904.102147705.davem@davemloft.net>
References: <201001071627.46569.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: hartleys@visionengravers.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754584Ab0AHA7A@vger.kernel.org>
In-Reply-To: <201001071627.46569.hartleys@visionengravers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: H Hartley Sweeten <hartleys@visionengravers.com>
Date: Thu, 7 Jan 2010 16:27:46 -0700

> Use the %pMF kernel extension to display the MAC address.
> 
> The address will still be displayed in the FDDI Canonical format.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

Applied.
