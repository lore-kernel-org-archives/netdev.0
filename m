From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] smsc95xx: fix register dump of last register
Date: Mon, 10 Dec 2012 14:10:14 -0500 (EST)
Message-ID: <20121210.141014.274596255061800879.davem@davemloft.net>
References: <1355137388-2938-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751950Ab2LJTKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 14:10:16 -0500
In-Reply-To: <1355137388-2938-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@shawell.net>
Date: Mon, 10 Dec 2012 11:03:07 +0000

> This patch fixes the ethtool register dump for smsc95xx to dump
> all 4 bytes of the final register (COE_CR) instead of just the
> first byte.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>

Applied.
