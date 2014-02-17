From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 0/4] bonding cleaning
Date: Mon, 17 Feb 2014 09:00:47 +0800
Message-ID: <53015F3F.30409@huawei.com>
References: <cover.1392508410.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392508410.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/2/16 7:57, Joe Perches wrote:
> Miscellaneous cleanups
> 
> Joe Perches (4):
>   bonding: Convert pr_warning to pr_warn, neatening
>   bonding: Neaten pr_<level>
>   bonding: Convert c99 comments
>   bonding: Convert memcpy(foo, bar, ETH_ALEN) to ether_addr_copy(foo, bar)
> 
>  drivers/net/bonding/bond_3ad.c     |  19 +--
>  drivers/net/bonding/bond_3ad.h     | 175 ++++++++++++++--------------
>  drivers/net/bonding/bond_alb.c     |  36 +++---
>  drivers/net/bonding/bond_debugfs.c |  10 +-
>  drivers/net/bonding/bond_main.c    | 231 ++++++++++++++++++-------------------
>  drivers/net/bonding/bond_netlink.c |   6 +-
>  drivers/net/bonding/bond_options.c | 102 ++++++++--------
>  drivers/net/bonding/bond_procfs.c  |   8 +-
>  drivers/net/bonding/bond_sysfs.c   |   8 +-
>  9 files changed, 288 insertions(+), 307 deletions(-)
> 

Reviewed-by: Ding Tianhong <dingtianhong@huawei.com>
