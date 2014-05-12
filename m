From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RESEND] vlan: rename __vlan_find_dev_deep() to
 __vlan_find_dev_deep_rcu_rcu()
Date: Mon, 12 May 2014 14:39:56 -0400 (EDT)
Message-ID: <20140512.143956.2213504439730586014.davem@davemloft.net>
References: <536C7C7D.1080603@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, oliver@neukum.org,
	stephen@networkplumber.org
To: dingtianhong@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <536C7C7D.1080603@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Fri, 9 May 2014 14:58:05 +0800

> The __vlan_find_dev_deep should always called in RCU, according
> David's suggestion, rename to __vlan_find_dev_deep_rcu looks more
> reasonable.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied with subject corrected (too many "rcu"'s :-)

Thanks.
