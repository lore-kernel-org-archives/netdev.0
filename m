From: David Miller <davem@davemloft.net>
Subject: Re: [BUG PATCH] Memory leak on tcp_prot slab with TPROXY and TCP
 early demux
Date: Mon, 27 Jan 2014 16:23:18 -0800 (PST)
Message-ID: <20140127.162318.1731809648251258860.davem@davemloft.net>
References: <20140127093317.GU7176@imap.eitzenberger.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	fw@strlen.de
To: holger@eitzenberger.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbaA1AXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 19:23:19 -0500
In-Reply-To: <20140127093317.GU7176@imap.eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Eitzenberger <holger@eitzenberger.org>
Date: Mon, 27 Jan 2014 10:33:18 +0100

> Please have a look, there could be smarter ways of fixing that.

Looks good, applied and queued up for -stable.

Thanks!
