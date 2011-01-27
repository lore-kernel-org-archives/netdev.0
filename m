From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next-2.6] drivers/net: remove some rcu sparse warnings
Date: Thu, 27 Jan 2011 10:22:20 +0100
Message-ID: <201101271022.21330.arnd@arndb.de>
References: <1296106103.1783.114.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:58604 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858Ab1A0JW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 04:22:59 -0500
In-Reply-To: <1296106103.1783.114.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 January 2011, Eric Dumazet wrote:
> Add missing __rcu annotations and helpers.
> minor : Fix some rcu_dereference() calls in macvtap
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Arnd Bergmann <arnd@arndb.de>
> CC: Michael Chan <mchan@broadcom.com>
> CC: Eilon Greenstein <eilong@broadcom.com>

Macvtap bits look good, thanks!

Acked-by: Arnd Bergmann <arnd@arndb.de>

