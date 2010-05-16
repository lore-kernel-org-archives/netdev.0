From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v10 0/3] net: reserve ports for applications using
 fixed port numbers
Date: Sat, 15 May 2010 23:28:48 -0700 (PDT)
Message-ID: <20100515.232848.137856613.davem@davemloft.net>
References: <20100505103033.5600.77502.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, opurdila@ixiacom.com,
	ebiederm@xmission.com, eric.dumazet@gmail.com,
	penguin-kernel@I-love.SAKURA.ne.jp, netdev@vger.kernel.org,
	nhorman@tuxdriver.com, xiaosuo@gmail.com, adobriyan@gmail.com
To: amwang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100505103033.5600.77502.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amerigo Wang <amwang@redhat.com>
Date: Wed, 5 May 2010 06:26:34 -0400

> 
> Changes from the previous version:
> - Use 'true' and 'false' for bool's;
> - Fix some coding style problems;
> - Allow appending lines to bitmap proc file so that it will be
>   easier to add new bits.

Applied to net-next-2.6, thanks.
