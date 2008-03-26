From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 2/4][NETNS][ICMP]: Move ICMP sysctls on
 struct net.
Date: Wed, 26 Mar 2008 01:55:48 -0700 (PDT)
Message-ID: <20080326.015548.218611168.davem@davemloft.net>
References: <47EA0EEF.4090905@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46279
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751381AbYCZIzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 04:55:49 -0400
In-Reply-To: <47EA0EEF.4090905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 26 Mar 2008 11:53:03 +0300

> Initialization is moved to icmp_sk_init, all the places, that
> refer to them use init_net for now.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
