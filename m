From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] net:atm:fix up ENOIOCTLCMD error handling
Date: Fri, 31 Aug 2012 16:14:43 -0400 (EDT)
Message-ID: <20120831.161443.124994431345620659.davem@davemloft.net>
References: <1346052196-32682-1-git-send-email-gaowanlong@cn.fujitsu.com>
	<1346052196-32682-3-git-send-email-gaowanlong@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: gaowanlong@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1346052196-32682-3-git-send-email-gaowanlong@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Date: Mon, 27 Aug 2012 15:23:13 +0800

> At commit 07d106d0, Linus pointed out that ENOIOCTLCMD should be
> translated as ENOTTY to user mode.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>

Applied to net-next, thanks.
