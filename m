From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix dev_mc_add()
Date: Wed, 10 Mar 2010 07:34:57 -0800 (PST)
Message-ID: <20100310.073457.164055652.davem@davemloft.net>
References: <1268197748.2872.129.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jpirko@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53862
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756690Ab0CJPei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 10:34:38 -0500
In-Reply-To: <1268197748.2872.129.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 10 Mar 2010 06:09:08 +0100

> Commit 6e17d45a (net: add addr len check to dev_mc_add)
> added a bug in dev_mc_add(), since it can now exit with a lock
> imbalance.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Jiri Pirko <jpirko@redhat.com>

Applied.
