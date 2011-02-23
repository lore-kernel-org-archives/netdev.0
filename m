From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-next-2.6] r6040: fix multicast operations
Date: Wed, 23 Feb 2011 14:35:58 -0800 (PST)
Message-ID: <20110223.143558.102556959.davem@davemloft.net>
References: <201102231532.34849.florian@openwrt.org>
	<20110223.142254.59671988.davem@davemloft.net>
	<201102232332.40712.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58306
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754401Ab1BWWfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 17:35:22 -0500
In-Reply-To: <201102232332.40712.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Wed, 23 Feb 2011 23:32:40 +0100

> It is appropriate for kernel versions including e1d44477 (net: convert 
> multiple drivers to use netdev_for_each_mc_addr). The patch was generated from 
> a net-next-2.6 tree, thus the mention in the subject, which was certainly 
> misleading, sorry about that.

There is no disconnect between those two things, what tree a patch
applies cleanly against and what tree it is meant to be applied to.

They are always equal.

There is therefore no confusion, and it was not misleading.
