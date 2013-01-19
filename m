From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2013-01-19
Date: Sat, 19 Jan 2013 10:50:17 -0500 (EST)
Message-ID: <20130119.105017.886816855929937540.davem@davemloft.net>
References: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47149 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250Ab3ASPuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 10:50:18 -0500
In-Reply-To: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Sat, 19 Jan 2013 21:27:46 +0800

> here is our second patchset intended for net-next/linux-3.9.
> In this batch you have some struct refactoring and a great kernel doc
> improvement by Marek Lindner. In patch 10/13 you have the random32() function
> renaming proposed by Akinobu Mita.
> 
> In 11/13 instead you have a behavioural change brought by Simon Wunderlich which
> is modifying the way a batman-adv virtual interface is unregistered in order to
> prevent a possible deadlock involving rntl_lock and s_active. We have
> already been discussing about this problem and its possible solution on the
> netdev mailing list.
> The rest is just clean up work.
> 
> Please pull or let me know if there is any problem.

Pulled, thanks Antonio.
