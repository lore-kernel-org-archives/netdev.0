From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] bonding: locking simplifications and
 cleanup
Date: Wed, 04 Sep 2013 00:52:28 -0400 (EDT)
Message-ID: <20130904.005228.1470802886437069263.davem@davemloft.net>
References: <1378122702-28943-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755930Ab3IDEwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 00:52:33 -0400
In-Reply-To: <1378122702-28943-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Mon,  2 Sep 2013 13:51:37 +0200

> This small patchset aims to remove some use cases of bond->lock for mutual
> exclusion which will help in the RCUfication of the function users. It also
> does some small style cleanups and fixes.

Series applied.
