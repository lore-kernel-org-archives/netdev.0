From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] bonding: remove ifenslave.c from kernel source
Date: Mon, 27 May 2013 23:35:57 -0700 (PDT)
Message-ID: <20130527.233557.337411213231291183.davem@davemloft.net>
References: <1369705756-11171-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	fubar@us.ibm.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53383 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933056Ab3E1Gf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 02:35:59 -0400
In-Reply-To: <1369705756-11171-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 28 May 2013 09:49:16 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> As Stephen proposed:
> Since bonding supports configuration via iproute (netlink) and sysfs, I think
> it is time to purge the old ifenslave code out of Documentation/networking
> and update the documentation.
> 
> Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Yep, time to let this one go, applied, thanks!
