From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] vlan: slight optimization for vlan core
Date: Sun, 09 Mar 2014 19:04:05 -0400 (EDT)
Message-ID: <20140309.190405.859762810633853061.davem@davemloft.net>
References: <1394189131-3916-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, joe@perches.com, julia.lawall@lip6.fr,
	netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36875 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbaCIXEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 19:04:07 -0400
In-Reply-To: <1394189131-3916-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Fri, 7 Mar 2014 18:45:29 +0800

> Ding Tianhong (2):
>   vlan: slight optimization for vlan_do_receive()
>   vlan: use use ether_addr_equal_64bits to instead of ether_addr_equal

Both applied, thanks Ding.
