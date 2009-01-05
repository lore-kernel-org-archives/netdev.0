From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] DCB: fix kfree(skb)
Date: Sun, 04 Jan 2009 17:29:29 -0800 (PST)
Message-ID: <20090104.172929.258785346.davem@davemloft.net>
References: <495E1096.5060201@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37750
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751342AbZAEB3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 20:29:25 -0500
In-Reply-To: <495E1096.5060201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Fri, 02 Jan 2009 14:03:18 +0100

> Use kfree_skb instead of kfree for struct sk_buff pointers.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied, thanks a lot Roel.
