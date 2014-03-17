From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Beautify 'sh_eth' driver's messages
Date: Mon, 17 Mar 2014 16:07:16 -0400 (EDT)
Message-ID: <20140317.160716.1032368159779908756.davem@davemloft.net>
References: <201403150321.47674.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201403150321.47674.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sat, 15 Mar 2014 03:21:47 +0300

> This patchset converts te driver to using netdev_*() and netif_*() to print out
> its messages whenever possible.
> 
> [1/3] sh_eth: convert pr_*() to netdev_*() calls
> [2/3] sh_eth: convert dev_*() to netdev_*() calls
> [3/3] sh_eth: fold netif_msg_*() and dev_*() calls into netif_*() invocations

Series applied to net-next, thanks.
