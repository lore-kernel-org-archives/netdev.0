From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tilegx: request_irq with a non-null device name
Date: Fri, 16 Nov 2012 01:40:56 -0500 (EST)
Message-ID: <20121116.014056.1166943441654050720.davem@davemloft.net>
References: <1353039199-12520-1-git-send-email-simon.marchi@polymtl.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	cmetcalf@tilera.com
To: simon.marchi@polymtl.ca
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1353039199-12520-1-git-send-email-simon.marchi@polymtl.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Marchi <simon.marchi@polymtl.ca>
Date: Thu, 15 Nov 2012 23:13:19 -0500

> This patch simply makes the tilegx net driver call request_irq with a
> non-null name. It makes the output in /proc/interrupts more obvious, but
> also helps tools that don't expect to find null there.
> 
> Signed-off-by: Simon Marchi <simon.marchi@polymtl.ca>
> Acked-by: Chris Metcalf <cmetcalf@tilera.com>

Applied, thanks.
