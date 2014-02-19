From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next 0/3] bonding: More ether_addr_copy and
 neatenings.
Date: Wed, 19 Feb 2014 15:38:23 -0500 (EST)
Message-ID: <20140219.153823.2104782869234968037.davem@redhat.com>
References: <cover.1392745013.git.joe@perches.com>
	<53040C96.2020600@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53040C96.2020600@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Wed, 19 Feb 2014 09:44:54 +0800

> On 2014/2/19 1:42, Joe Perches wrote:
>> Joe Perches (3):
>>   bonding: More use of ether_addr_copy
>>   bonding: Remove unnecessary else
>>   bonding: Invert test
>> 
>>  drivers/net/bonding/bond_3ad.c  | 21 ++++++++++-----------
>>  drivers/net/bonding/bond_alb.c  | 17 ++++++++---------
>>  drivers/net/bonding/bond_main.c |  6 +++---
>>  3 files changed, 21 insertions(+), 23 deletions(-)
>> 
> 
> Reviewed-by: Ding Tianhong <dingtianhong@huawei.com>

Series applied, thanks Joe.
