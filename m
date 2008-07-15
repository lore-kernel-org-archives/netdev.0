From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/7] ICMP: add struct net argument to
 icmp_out_count
Date: Mon, 14 Jul 2008 23:01:06 -0700 (PDT)
Message-ID: <20080714.230106.147023557.davem@davemloft.net>
References: <4871F2D8.8030502@openvz.org>
	<4871F376.3060609@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56766
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752054AbYGOGBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 02:01:05 -0400
In-Reply-To: <4871F376.3060609@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 07 Jul 2008 14:44:06 +0400

> This routine deals with ICMP statistics, but doesn't have a
> struct net at hands, so add one.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.

Please use lowercase subsystem names in commit header lines
in the future, I fixed it up this time.

Thanks!
