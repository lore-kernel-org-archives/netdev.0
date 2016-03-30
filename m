From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] bond: output message before setting slave to
 inactive
Date: Wed, 30 Mar 2016 15:37:03 -0400 (EDT)
Message-ID: <20160330.153703.583823625143126389.davem@davemloft.net>
References: <1459233177-6394-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37329 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752247AbcC3ThI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 15:37:08 -0400
In-Reply-To: <1459233177-6394-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Tue, 29 Mar 2016 06:32:57 +0000

> This patch moves output message before setting slave to inactive, this will
> print the correct status of slave device.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

I think the message is in the appropriate spot wrt. state, so I will not
apply this, thanks.
