From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: netlink_getname, packet_getname -- use
 DECLARE_SOCKADDR guard
Date: Tue, 10 Nov 2009 22:31:35 -0800 (PST)
Message-ID: <20091110.223135.75727004.davem@davemloft.net>
References: <20091108155119.GA25940@lenovo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: gorcunov@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59175
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752494AbZKKGbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 01:31:09 -0500
In-Reply-To: <20091108155119.GA25940@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@openvz.org>
Date: Sun, 8 Nov 2009 18:51:19 +0300

> Use guard DECLARE_SOCKADDR in a few more places which allow
> us to catch if the structure copied back is too big.
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>

Applied to net-next-2.6, thanks.
