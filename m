From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/2] dev: update __dev_notify_flags() to
 send rtnl msg
Date: Mon, 30 Sep 2013 15:08:50 -0400 (EDT)
Message-ID: <20130930.150850.57655941771317776.davem@davemloft.net>
References: <20130924094707.41641042@nehalam.linuxnetplumber.net>
	<1380103365-5185-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755960Ab3I3TIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 15:08:52 -0400
In-Reply-To: <1380103365-5185-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 25 Sep 2013 12:02:44 +0200

> This patch only prepares the next one, there is no functional change.
> Now, __dev_notify_flags() can also be used to notify flags changes via
> rtnetlink.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
