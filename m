From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] dlci: acquire rtnl_lock before calling
 __dev_get_by_name()
Date: Wed, 26 Jun 2013 15:46:26 -0700 (PDT)
Message-ID: <20130626.154626.1312386779386420575.davem@davemloft.net>
References: <51CA9872.5050700@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: lizefan@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51CA9872.5050700@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Li Zefan <lizefan@huawei.com>
Date: Wed, 26 Jun 2013 15:29:54 +0800

> Otherwise the net device returned can be freed at anytime.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Applied and queued up for -stable.
