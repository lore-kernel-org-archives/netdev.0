From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix ad_select module param check
Date: Mon, 14 Jul 2014 14:37:38 -0700 (PDT)
Message-ID: <20140714.143738.1606528197355521840.davem@davemloft.net>
References: <1405237667-17531-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35967 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756734AbaGNVhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 17:37:39 -0400
In-Reply-To: <1405237667-17531-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Sun, 13 Jul 2014 09:47:47 +0200

> Obvious copy/paste error when I converted the ad_select to the new
> option API. "lacp_rate" there should be "ad_select" so we can get the
> proper value.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: David S. Miller <davem@davemloft.net>
> 
> Fixes: 9e5f5eebe765 ("bonding: convert ad_select to use the new option
> API")
> Reported-by: Karim Scheik <karim.scheik@prisma-solutions.at>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied and queued up for -stable, thanks.
