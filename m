From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: Don't destroy the netdev until the vif is
 shut
Date: Fri, 04 Oct 2013 00:22:48 -0400 (EDT)
Message-ID: <20131004.002248.789391156050342547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wei.liu2@citrix.com
To: Paul.Durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44199 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753Ab3JDEWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 00:22:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Can one of you do -stable backports of this change for v3.11 and any
other active -stable branch where this fix is relevant?

I gave it a shot, and it got outside my realm of expertise.

Thanks!
