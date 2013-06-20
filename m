From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: trivial: make alb use
 bond_slave_has_mac()
Date: Wed, 19 Jun 2013 22:20:25 -0700 (PDT)
Message-ID: <20130619.222025.388299765979227331.davem@davemloft.net>
References: <1371555892-1934-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49409 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611Ab3FTFU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 01:20:26 -0400
In-Reply-To: <1371555892-1934-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 18 Jun 2013 13:44:52 +0200

> Also, cleanup bond_alb_handle_active_change() from 2 identical ifs.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied.
