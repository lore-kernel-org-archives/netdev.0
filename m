From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] 6lowpan: cleanup header creation
Date: Wed, 30 Oct 2013 17:19:15 -0400 (EDT)
Message-ID: <20131030.171915.285130438459697449.davem@davemloft.net>
References: <1383121104-2515-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	dbaryshkov@gmail.com, netdev@vger.kernel.org
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34541 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391Ab3J3VTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 17:19:17 -0400
In-Reply-To: <1383121104-2515-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Wed, 30 Oct 2013 09:18:20 +0100

> This patch series cleanup the 6LoWPAN header creation and extend the use
> of skb_*_header functions.
> 
> Patch 2/4 fix issues of parsing the mac header. The ieee802.15.4 header
> has a dynamic size which depends on frame control bits. This patch replaces the
> static mac header len calculation with a dynamic one.

Series applied, thanks.
