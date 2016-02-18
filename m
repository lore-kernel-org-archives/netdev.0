From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2] vlan: change return type of vlan_proc_rem_dev
Date: Wed, 17 Feb 2016 22:07:06 -0500 (EST)
Message-ID: <20160217.220706.1131036375103426989.davem@davemloft.net>
References: <1455762570-12019-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33448 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424050AbcBRDHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 22:07:07 -0500
In-Reply-To: <1455762570-12019-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Thu, 18 Feb 2016 02:29:30 +0000

> Since function vlan_proc_rem_dev() will only return 0, it's better to
> return void instead of int.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied, thanks.
