From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Don't allow bond devices to change network
 namespaces.
Date: Wed, 22 Jan 2014 21:59:18 -0800 (PST)
Message-ID: <20140122.215918.1452986247141274817.davem@davemloft.net>
References: <1390382190-1604-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: chenweilong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54145 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932125AbaAWF7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 00:59:19 -0500
In-Reply-To: <1390382190-1604-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Weilong <chenweilong@huawei.com>
Date: Wed, 22 Jan 2014 17:16:30 +0800

> From: Weilong Chen <chenweilong@huawei.com>
> 
> Like bridge, bonding as netdevice doesn't cross netns boundaries.
> 
> Bonding ports and bonding itself live in same netns.
> 
> Signed-off-by: Weilong Chen <chenweilong@huawei.com>

Applied.
