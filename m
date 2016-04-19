From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] drivers: net: cpsw: Prevent NUll pointer
 dereference with two PHYs
Date: Tue, 19 Apr 2016 12:05:28 -0400 (EDT)
Message-ID: <20160419.120528.249343005652011691.davem@davemloft.net>
References: <1461074186-25535-1-git-send-email-andrew.goodbody@cambrionix.com>
	<1461074186-25535-2-git-send-email-andrew.goodbody@cambrionix.com>
	<57164383.6080103@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew.goodbody@cambrionix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	mugunthanvnm@ti.com, tony@atomide.com
To: grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57164383.6080103@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Tue, 19 Apr 2016 17:41:07 +0300

> David, Is it possible to drop prev version of this patch from linux-next
> - it breaks boot on many TI boards with -next.

It doesn't work that way, I cannot "drop" patches.

One has to send me a fix to the existing patch, or a revert.
