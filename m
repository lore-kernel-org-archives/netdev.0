From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/2] sctp: fix kfree static array pointer in
 sctp_sysctl_net_unregister
Date: Fri, 09 May 2014 16:41:43 -0400 (EDT)
Message-ID: <20140509.164143.1972373677615840350.davem@davemloft.net>
References: <1399553702-7960-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, dborkman@redhat.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39515 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756796AbaEIUlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 16:41:45 -0400
In-Reply-To: <1399553702-7960-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Thu, 8 May 2014 20:55:00 +0800

> patch #1 revert the efb842c45("sctp: optimize the sctp_sysctl_net_register")
> patch #2 add a checking for sctp_sysctl_net_register

Series applied, thanks.
