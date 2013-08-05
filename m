From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] vlan: make vlan_dev_real_dev work over stacked
 vlans
Date: Mon, 05 Aug 2013 12:18:27 -0700 (PDT)
Message-ID: <20130805.121827.266175783715214456.davem@davemloft.net>
References: <1375560467-1604-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@redhat.com, fubar@us.ibm.com,
	jhs@mojatatu.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48349 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754343Ab3HETSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 15:18:31 -0400
In-Reply-To: <1375560467-1604-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Sat,  3 Aug 2013 22:07:46 +0200

> From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>
> 
> Sometimes we might have stacked vlans on top of each other, and we're
> interested in the first non-vlan real device on the path, so transform
> vlan_dev_real_dev to go over the stacked vlans and extract the first
> non-vlan device.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied.
