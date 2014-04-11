From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Bonding Remove debug_fs files when module init fails
Date: Fri, 11 Apr 2014 15:09:09 -0400 (EDT)
Message-ID: <20140411.150909.210448793715249166.davem@davemloft.net>
References: <1397040779-8699-1-git-send-email-tmricht@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tmricht@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58157 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754381AbaDKTJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 15:09:11 -0400
In-Reply-To: <1397040779-8699-1-git-send-email-tmricht@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>
Date: Wed,  9 Apr 2014 12:52:59 +0200

> Remove the bonding debug_fs entries when the
> module initialization fails. The debug_fs
> entries should be removed together with all other
> already allocated resources.
> 
> Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>

Applied, thanks.
