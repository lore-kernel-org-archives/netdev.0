From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] [IPV4] Thresholds in fib_trie.c are used as
 consts, so make them const.
Date: Thu, 13 Dec 2007 09:48:14 -0800 (PST)
Message-ID: <20071213.094814.208890787.davem@davemloft.net>
References: <20071213080618.GA6530@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34497
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763025AbXLMRsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 12:48:15 -0500
In-Reply-To: <20071213080618.GA6530@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 13 Dec 2007 11:06:18 +0300

> [IPV4] Thresholds in fib_trie.c are used as consts, so make them const.
> 
> There are several thresholds for trie fib hash management. They are used
> in the code as a constants. Make them constants from the compiler point of
> view.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks for fixing this patch up.
