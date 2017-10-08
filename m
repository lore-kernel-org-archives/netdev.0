From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,0/3] hv_netvsc: support changing TCP hash level
Date: Sun, 08 Oct 2017 10:11:14 -0700 (PDT)
Message-ID: <20171008.101114.578720455778889533.davem@davemloft.net>
References: <20171006153359.8400-1-haiyangz@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, sthemmin@microsoft.com,
        olaf@aepfle.de, vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com, haiyangz@exchange.microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171006153359.8400-1-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Date: Fri,  6 Oct 2017 08:33:56 -0700

> From: Haiyang Zhang <haiyangz@microsoft.com>
> 
> The patch set simplifies the existing hash level switching code for
> UDP. It also adds the support for changing TCP hash level. So users
> can switch between L3 an L4 hash levels for TCP and UDP.

Series applied.
