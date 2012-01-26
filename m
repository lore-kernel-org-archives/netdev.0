From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH rhel6] Allow ipv6 proxies and arp proxies be shown with
 iproute2
Date: Thu, 26 Jan 2012 13:14:21 -0500 (EST)
Message-ID: <20120126.131421.493688359096317561.davem@davemloft.net>
References: <1327589392-10852-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, devel@openvz.org, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org
To: antonz@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601Ab2AZSO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 13:14:58 -0500
In-Reply-To: <1327589392-10852-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Zelenoff <antonz@parallels.com>
Date: Thu, 26 Jan 2012 18:49:52 +0400

> +	/* check for full ndmsg structure presence, family member is
> +	 * the same for both structures */

/* Please format
 * comments, like this.
 */

/* Not,
 * like this. */
