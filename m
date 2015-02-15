From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: Fix key serialization.
Date: Sat, 14 Feb 2015 20:21:39 -0800 (PST)
Message-ID: <20150214.202139.1740770935684562032.davem@davemloft.net>
References: <1423763928-1554-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joestringer@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754441AbbBOEOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2015 23:14:31 -0500
In-Reply-To: <1423763928-1554-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 12 Feb 2015 09:58:48 -0800

> Fix typo where mask is used rather than key.
> 
> Fixes: 74ed7ab9264("openvswitch: Add support for unique flow IDs.")
> Reported-by: Joe Stringer <joestringer@nicira.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
