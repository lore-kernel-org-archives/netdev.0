From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 0/3] bonding: More ether_addr_copy and neatenings.
Date: Wed, 19 Feb 2014 09:44:54 +0800
Message-ID: <53040C96.2020600@huawei.com>
References: <cover.1392745013.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392745013.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/2/19 1:42, Joe Perches wrote:
> Joe Perches (3):
>   bonding: More use of ether_addr_copy
>   bonding: Remove unnecessary else
>   bonding: Invert test
> 
>  drivers/net/bonding/bond_3ad.c  | 21 ++++++++++-----------
>  drivers/net/bonding/bond_alb.c  | 17 ++++++++---------
>  drivers/net/bonding/bond_main.c |  6 +++---
>  3 files changed, 21 insertions(+), 23 deletions(-)
> 

Reviewed-by: Ding Tianhong <dingtianhong@huawei.com>
