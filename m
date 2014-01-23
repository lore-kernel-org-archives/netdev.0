From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] team: Don't allow team devices to change network
 namespaces.
Date: Wed, 22 Jan 2014 21:59:33 -0800 (PST)
Message-ID: <20140122.215933.488434196268367900.davem@davemloft.net>
References: <1390446442-12768-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: chenweilong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbaAWF7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 00:59:34 -0500
In-Reply-To: <1390446442-12768-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Weilong <chenweilong@huawei.com>
Date: Thu, 23 Jan 2014 11:07:22 +0800

> From: Weilong Chen <chenweilong@huawei.com>
> 
> Like bonding, team as netdevice doesn't cross netns boundaries.
> 
> Team ports and team itself live in same netns.
> 
> Signed-off-by: Weilong Chen <chenweilong@huawei.com>

Applied.
