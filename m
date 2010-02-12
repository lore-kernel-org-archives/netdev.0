From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: use netdev_mc_count and
 netdev_mc_empty when appropriate
Date: Fri, 12 Feb 2010 11:39:13 -0800 (PST)
Message-ID: <20100212.113913.58700928.davem@davemloft.net>
References: <20100208143032.GD2601@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57007
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756463Ab0BLTi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 14:38:58 -0500
In-Reply-To: <20100208143032.GD2601@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Mon, 8 Feb 2010 15:30:35 +0100

> This patch replaces dev->mc_count in all drivers (hopefully I didn't miss
> anything). Used spatch and did small tweaks and conding style changes when
> it was suitable.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied to net-next-2.6, thanks.
