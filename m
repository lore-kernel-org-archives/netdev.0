From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bonding: fix miimon and arp_interval delayed work
 race conditions
Date: Thu, 29 Nov 2012 13:14:03 -0500 (EST)
Message-ID: <20121129.131403.1313317139099933995.davem@davemloft.net>
References: <1353759471-30323-1-git-send-email-nikolay@redhat.com>
	<1354188691-15509-1-git-send-email-nikolay@redhat.com>
	<13828.1354210651@death.nxdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33971 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100Ab2K2SOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:14:05 -0500
In-Reply-To: <13828.1354210651@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Thu, 29 Nov 2012 09:37:31 -0800

> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
 ...
>>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied.
