From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/atl1e/atl1e_main.c: use %pM to show MAC
 address
Date: Thu, 07 Jan 2010 01:18:43 -0800 (PST)
Message-ID: <20100107.011843.06550329.davem@davemloft.net>
References: <201001050955.40411.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: hartleys@visionengravers.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932989Ab0AGJSq@vger.kernel.org>
In-Reply-To: <201001050955.40411.hartleys@visionengravers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: H Hartley Sweeten <hartleys@visionengravers.com>
Date: Tue, 5 Jan 2010 09:55:40 -0700

> Use the %pM kernel extension to display the MAC address.
> 
> The only difference in the output is that the MAC address is
> shown in the usual colon-separated hex notation.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

Applied.
