From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] smsc95xx: add wol support for more frame types
Date: Wed, 31 Oct 2012 13:33:09 -0400 (EDT)
Message-ID: <20121031.133309.575670421875903399.davem@davemloft.net>
References: <1351259036-5375-1-git-send-email-steve.glendinning@shawell.net>
	<1351259036-5375-2-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933028Ab2JaRdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 13:33:13 -0400
In-Reply-To: <1351259036-5375-2-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@shawell.net>
Date: Fri, 26 Oct 2012 14:43:56 +0100

> This patch adds support for wol wakeup on unicast, broadcast,
> multicast and arp frames.
> 
> The wakeup filter code isn't pretty, but it works.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>

Applied.
