From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 1/4][NETNS][ICMP]: Register pernet subsys to
 make ICMP sysctls per-net.
Date: Wed, 26 Mar 2008 01:54:47 -0700 (PDT)
Message-ID: <20080326.015447.194529387.davem@davemloft.net>
References: <47EA0E89.5040200@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46276
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752729AbYCZIyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 04:54:49 -0400
In-Reply-To: <47EA0E89.5040200@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 26 Mar 2008 11:51:21 +0300

> This includes adding pernet_operations, empty init and exit
> hooks and a bit of changes in sysctl_ipv4_init just not to
> have this part in next patches.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
