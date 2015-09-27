From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/19] net: hisilicon: fix handling platform_get_irq
 result
Date: Sat, 26 Sep 2015 22:47:08 -0700 (PDT)
Message-ID: <20150926.224708.1856076171022986940.davem@davemloft.net>
References: <1443103227-25612-1-git-send-email-a.hajda@samsung.com>
	<1443103227-25612-8-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, b.zolnierkie@samsung.com,
	m.szyprowski@samsung.com, dingtianhong@huawei.com,
	netdev@vger.kernel.org
To: a.hajda@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443103227-25612-8-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrzej Hajda <a.hajda@samsung.com>
Date: Thu, 24 Sep 2015 16:00:15 +0200

> The function can return negative value.
> 
> The problem has been detected using proposed semantic patch
> scripts/coccinelle/tests/assign_signed_to_unsigned.cocci [1].
> 
> [1]: http://permalink.gmane.org/gmane.linux.kernel/2046107
> 
> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>

Applied.
