From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/hyperv: Use wait_event on outstanding sends during
 device removal
Date: Mon, 04 Jun 2012 14:11:46 -0400 (EDT)
Message-ID: <20120604.141146.798909958558510549.davem@davemloft.net>
References: <1338828158-3133-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338828158-3133-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Mon,  4 Jun 2012 09:42:38 -0700

> Change the busy-waiting/udelay to wait_event on outstanding sends.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
