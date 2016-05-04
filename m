From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] dmfe: kill DEVICE define
Date: Wed, 04 May 2016 14:13:58 -0400 (EDT)
Message-ID: <20160504.141358.593077400259537209.davem@davemloft.net>
References: <1462294395-20440-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41177 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755013AbcEDSOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 14:14:00 -0400
In-Reply-To: <1462294395-20440-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue,  3 May 2016 18:53:15 +0200

> use net_device directly. Compile tested, objdiff shows no changes.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
