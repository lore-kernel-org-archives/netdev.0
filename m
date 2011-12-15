From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] Explicitly call tcp creation and init from
 memcontrol.c
Date: Thu, 15 Dec 2011 11:57:10 -0500 (EST)
Message-ID: <20111215.115710.19471540928319216.davem@davemloft.net>
References: <1323941672-14324-1-git-send-email-glommer@parallels.com>
	<1323941672-14324-3-git-send-email-glommer@parallels.com>
	<20111216011316.8d58bc8f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: glommer@parallels.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, cgroups@vger.kernel.org,
	eric.dumazet@gmail.com, sfr@canb.auug.org.au
To: kamezawa.hiroyu@jp.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111216011316.8d58bc8f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 16 Dec 2011 01:13:16 +0900

> Could you remake the patch onto the 'latest' linux-next ?
> As Dave mentioned, some bandaids are already applied and this patch hunks.

He was correct to submit this against net-next.

The bandaid in linux-next is temporary and Stephen will remove it
once we fix things properly in net-next.
