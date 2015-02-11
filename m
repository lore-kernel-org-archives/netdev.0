From: David Miller <davem@davemloft.net>
Subject: Re: [trivial PATCH] treewide: Remove unnecessary
 BCMA_CORETABLE_END macro
Date: Wed, 11 Feb 2015 14:38:51 -0800 (PST)
Message-ID: <20150211.143851.1061242792059886308.davem@davemloft.net>
References: <1423601703.15343.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	linux-spi@vger.kernel.org, linux-usb@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423601703.15343.3.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 10 Feb 2015 12:55:03 -0800

> Use the normal {} instead of a macro to terminate an array.
> 
> Remove the macro too.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

I've applied both of your FOO_END removal patches, thanks Joe.
