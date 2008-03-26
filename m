From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 4/4][NETNS][ICMP]: Use per-net sysctls in
 ipv4/icmp.c.
Date: Wed, 26 Mar 2008 02:00:37 -0700 (PDT)
Message-ID: <20080326.020037.159176440.davem@davemloft.net>
References: <47EA1010.90705@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40103
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752625AbYCZJAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 05:00:38 -0400
In-Reply-To: <47EA1010.90705@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 26 Mar 2008 11:57:52 +0300

> This mostly re-uses the net, used in icmp netnsization patches from Denis.
> 
> After this ICMP sysctls are completely virtualized.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.
