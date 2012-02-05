From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net/hyperv: Correct the assignment in
 netvsc_recv_callback()
Date: Sun, 05 Feb 2012 17:45:59 -0500 (EST)
Message-ID: <20120205.174559.545816004267807280.davem@davemloft.net>
References: <1328479990-1436-1-git-send-email-haiyangz@microsoft.com>
	<1328479990-1436-2-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328479990-1436-2-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Sun,  5 Feb 2012 14:13:09 -0800

> The first assignment to variable "net" is wrong, but overridden by the
> latter assignments. So the bug isn't manifested.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
