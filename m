From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: trivial: remove unused parameter from
 alb_swap_mac_addr()
Date: Tue, 28 May 2013 23:57:51 -0700 (PDT)
Message-ID: <20130528.235751.1825713567297032704.davem@davemloft.net>
References: <1369732491-16847-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933908Ab3E2G5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 02:57:52 -0400
In-Reply-To: <1369732491-16847-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 28 May 2013 11:14:51 +0200

> After b924551 ("bonding: fix enslaving in alb mode when link down") we
> don't need the bond parameter in alb_swap_mac_addr(), so remove it.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied.
