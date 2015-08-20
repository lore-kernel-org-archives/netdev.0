From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] device property: Add ETH_ALEN check, update
 comments.
Date: Thu, 20 Aug 2015 14:37:37 -0700 (PDT)
Message-ID: <20150820.143737.960651130323110511.davem@davemloft.net>
References: <1440002803-5113-1-git-send-email-jeremy.linton@arm.com>
	<1440002803-5113-2-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	steve.glendinning@shawell.net, linux@roeck-us.net
To: jeremy.linton@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57335 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849AbbHTVhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 17:37:53 -0400
In-Reply-To: <1440002803-5113-2-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeremy Linton <jeremy.linton@arm.com>
Date: Wed, 19 Aug 2015 11:46:42 -0500

> This patch adds MAC address length check back into
> the device_get_mac_addr() function before calling
> is_valid_ether_addr() similar to the way the OF
> routine does it.
> 
> Update the comments for the two new functions.
> 
> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>

Applied.
