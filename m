From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] bridge: add support of adding and
 deleting mdb entries
Date: Wed, 12 Dec 2012 13:03:29 -0500 (EST)
Message-ID: <20121212.130329.1972887047089057344.davem@davemloft.net>
References: <1355300590-2390-1-git-send-email-amwang@redhat.com>
	<1355300590-2390-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	herbert@gondor.hengli.com.au, shemminger@vyatta.com, tgraf@suug.ch
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754353Ab2LLSDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 13:03:32 -0500
In-Reply-To: <1355300590-2390-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed, 12 Dec 2012 16:23:08 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> This patch implents adding/deleting mdb entries via netlink.
> Currently all entries are temp, we probably need a flag to distinguish
> permanent entries too.
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
