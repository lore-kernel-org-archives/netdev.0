From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: randomize port selection
Date: Fri, 24 Aug 2007 23:10:12 -0700 (PDT)
Message-ID: <20070824.231012.31596269.davem@davemloft.net>
References: <46CD3462.2070403@balabit.hu>
	<46CDBE17.7080909@hp.com>
	<20070823113226.30d6a4b6@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, panther@balabit.hu, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43001
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753001AbXHYGKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 02:10:13 -0400
In-Reply-To: <20070823113226.30d6a4b6@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 23 Aug 2007 11:32:26 -0700

> This patch causes UDP port allocation to be randomized like TCP.
> The earlier code would always choose same port (ie first empty list).
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied to net-2.6.24, thanks Stephen.
