From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 0/2] bonding: NULL pointer dereference and flag strip
 fixes
Date: Thu, 11 Apr 2013 16:02:43 -0400 (EDT)
Message-ID: <20130411.160243.351201200467404454.davem@davemloft.net>
References: <1365707936-5073-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38695 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838Ab3DKUCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 16:02:46 -0400
In-Reply-To: <1365707936-5073-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Thu, 11 Apr 2013 21:18:54 +0200

>  These 2 patches fix a NULL pointer dereference in the netdev event
>  handling of the bond and flag that wasn't stripped on enslave failure.
> 
> v2: Fix comment style 
> 
> Nikolay Aleksandrov (2):
>   bonding: fix netdev event NULL pointer dereference
>   bonding: IFF_BONDING is not stripped on enslave failure

Both applied, thanks.
