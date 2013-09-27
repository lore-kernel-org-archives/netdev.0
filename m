From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] hp100: replace hardcoded name in /proc/interrupts
 with interface name
Date: Fri, 27 Sep 2013 17:39:39 -0400 (EDT)
Message-ID: <20130927.173939.128432993141631731.davem@davemloft.net>
References: <1379789289-10961-1-git-send-email-me@mihirsingh.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: me@mihirsingh.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51012 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322Ab3I0Vjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 17:39:41 -0400
In-Reply-To: <1379789289-10961-1-git-send-email-me@mihirsingh.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mihir Singh <me@mihirsingh.com>
Date: Sat, 21 Sep 2013 18:48:09 +0000

> The /proc/interrupts file displays hp100, which is not the accepted style. Printing eth%d is more helpful.
> 
> Signed-off-by: Mihir Singh <me@mihirsingh.com>

Applied.
