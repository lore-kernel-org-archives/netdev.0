From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/defxx.c: use %pMF to show MAC address
Date: Thu, 07 Jan 2010 16:58:58 -0800 (PST)
Message-ID: <20100107.165858.199044029.davem@davemloft.net>
References: <201001071624.20139.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	macro@linux-mips.org
To: hartleys@visionengravers.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754560Ab0AHA6v@vger.kernel.org>
In-Reply-To: <201001071624.20139.hartleys@visionengravers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: H Hartley Sweeten <hartleys@visionengravers.com>
Date: Thu, 7 Jan 2010 16:24:19 -0700

> Use the %pMF kernel extension to display the MAC address.
> 
> The address will still be displayed in the FDDI Canonical format.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

Applied.
