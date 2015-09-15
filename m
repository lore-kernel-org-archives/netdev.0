From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [PATCH v3] add stealth mode
Date: Tue, 15 Sep 2015 12:00:57 -0700 (PDT)
Message-ID: <20150915.120057.1457031142615117336.davem@davemloft.net>
References: <1441183655-16970-1-git-send-email-matteo@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: matteo@openwrt.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441183655-16970-1-git-send-email-matteo@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matteo Croce <matteo@openwrt.org>
Date: Wed,  2 Sep 2015 10:47:35 +0200

> Add option to disable any reply not related to a listening socket,
> like RST/ACK for TCP and ICMP Port-Unreachable for UDP.
> Also disables ICMP replies to echo request and timestamp.
> The stealth mode can be enabled selectively for a single interface.
> 
> Signed-off-by: Matteo Croce <matteo@openwrt.org>

This doesn't apply cleanly to the current tree, please respin.

Thanks.
