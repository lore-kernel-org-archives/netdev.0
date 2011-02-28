From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] enic: Flush driver cache of registered
 addr lists during port profile disassociate
Date: Mon, 28 Feb 2011 12:42:45 -0800 (PST)
Message-ID: <20110228.124245.35040857.davem@davemloft.net>
References: <20110224011601.16406.36125.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roprabhu@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56407
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753325Ab1B1UmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 15:42:08 -0500
In-Reply-To: <20110224011601.16406.36125.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>
Date: Wed, 23 Feb 2011 17:16:01 -0800

> From: Roopa Prabhu <roprabhu@cisco.com>
> 
> During a port profile disassociate all address registrations for the interface
> are blown away from the adapter. This patch resets the driver cache of
> registered address lists to zero after a port profile disassociate.
> 
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>
> Signed-off-by: Christian Benvenuti <benve@cisco.com>

Applied.
