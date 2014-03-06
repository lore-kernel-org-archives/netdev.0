From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] 6lowpan: header cleanup
Date: Thu, 06 Mar 2014 17:22:21 -0500 (EST)
Message-ID: <20140306.172221.439306848276682730.davem@davemloft.net>
References: <1394026145-18981-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbaCFWWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 17:22:25 -0500
In-Reply-To: <1394026145-18981-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Wed,  5 Mar 2014 14:29:03 +0100

> this patch series fix a missing include of 6LoWPAN header and move it
> into the include/net directory. Since we did some code sharing with
> bluetooth 6LoWPAN the header turns into a generic header for 6LoWPAN.
> Instead to use a relative path in bluetooth 6LoWPAN we can now use
> include <net/6lowpan.h>.

Series applied, thanks Alex.
