From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,1/2] hv_netvsc: Remove unnecessary var
 link_state from struct netvsc_device_info
Date: Thu, 22 Jun 2017 13:30:46 -0400 (EDT)
Message-ID: <20170622.133046.2053486147865271098.davem@davemloft.net>
References: <1498088447-27282-1-git-send-email-haiyangz@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com, haiyangz@exchange.microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498088447-27282-1-git-send-email-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Date: Wed, 21 Jun 2017 16:40:46 -0700

> From: Haiyang Zhang <haiyangz@microsoft.com>
> 
> We simply use rndis_device->link_state in the netdev_dbg. The variable,
> link_state from struct netvsc_device_info, is not used anywhere else.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied.
