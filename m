From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next-2.6] drivers/net: remove some rcu sparse
 warnings
Date: Thu, 27 Jan 2011 10:32:31 -0800
Message-ID: <1296153151.8132.19.camel@HP1>
References: <1296106103.1783.114.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, "Arnd Bergmann" <arnd@arndb.de>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4526 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751423Ab1A0Sgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jan 2011 13:36:47 -0500
In-Reply-To: <1296106103.1783.114.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2011-01-26 at 21:28 -0800, Eric Dumazet wrote:
> Add missing __rcu annotations and helpers.
> minor : Fix some rcu_dereference() calls in macvtap
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Arnd Bergmann <arnd@arndb.de>
> CC: Michael Chan <mchan@broadcom.com>
> CC: Eilon Greenstein <eilong@broadcom.com>

Thanks Eric.  bnx2/bnx2x/cnic portions look good.
Acked-by: Michael Chan <mchan@broadcom.com>


