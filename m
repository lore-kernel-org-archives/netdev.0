From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26][NETNS][ICMP]: Build fix for NET_NS=n case
 (dev->nd_net is omitted).
Date: Wed, 26 Mar 2008 02:19:40 -0700 (PDT)
Message-ID: <20080326.021940.29039999.davem@davemloft.net>
References: <47EA1457.3010706@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36034
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753539AbYCZJTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 05:19:41 -0400
In-Reply-To: <47EA1457.3010706@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 26 Mar 2008 12:16:07 +0300

> I didn't check the kernel build after pulling dev->nd_net access 
> optimization from net-2.6.26 tree :(
> 
> Sorry.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.
