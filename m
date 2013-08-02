From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: netlink: minor: remove unused pointer in
 alloc_pg_vec
Date: Fri, 02 Aug 2013 15:26:30 -0700 (PDT)
Message-ID: <20130802.152630.507572432394571169.davem@davemloft.net>
References: <1375457559-7565-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42529 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753554Ab3HBW0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 18:26:31 -0400
In-Reply-To: <1375457559-7565-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri,  2 Aug 2013 17:32:39 +0200

> Variable ptr is being assigned, but never used, so just remove it.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks Daniel.
