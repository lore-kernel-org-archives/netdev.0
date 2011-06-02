From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6] bonding: allow all slave speeds
Date: Thu, 02 Jun 2011 14:44:14 -0700 (PDT)
Message-ID: <20110602.144414.873896883228591612.davem@davemloft.net>
References: <1306960593-16347-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754670Ab1FBVoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 17:44:20 -0400
In-Reply-To: <1306960593-16347-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed,  1 Jun 2011 22:36:33 +0200

> No need to check for 10, 100, 1000, 10000 explicitly. Just make this
> generic and check for invalid values only (similar check is in ethtool
> userspace app). This enables correct speed handling for slave devices
> with "nonstandard" speeds.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks.
