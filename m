From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bonding: clean rlb vlan use
Date: Tue, 03 Sep 2013 22:02:45 -0400 (EDT)
Message-ID: <20130903.220245.1465674958609552899.davem@davemloft.net>
References: <1377812337-19551-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934114Ab3IDCCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 22:02:46 -0400
In-Reply-To: <1377812337-19551-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Thu, 29 Aug 2013 23:38:55 +0200

> Finish the vlan cleanup, only rlb left.
> 
> Remove the bond_vlan_used() function, it's useless anyway, and
> rlb_client_info->tag, cause we can use only ->vlan_id.
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied, thanks.
