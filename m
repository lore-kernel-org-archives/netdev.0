From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: bridge: add compile-time assert for cb struct
 size
Date: Tue, 03 Mar 2015 14:07:21 -0500 (EST)
Message-ID: <20150303.140721.615156837917181755.davem@davemloft.net>
References: <1425387211-16807-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36341 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbbCCTHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 14:07:23 -0500
In-Reply-To: <1425387211-16807-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue,  3 Mar 2015 13:53:31 +0100

> make build fail if structure no longer fits into ->cb storage.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks Florian.
