From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv6: remove a useless pr_info() in
 addrconf_gre_config()
Date: Sun, 23 Jun 2013 18:47:07 -0700 (PDT)
Message-ID: <20130623.184707.1649970044060368207.davem@davemloft.net>
References: <1371717000-22295-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35088 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989Ab3FXBrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 21:47:08 -0400
In-Reply-To: <1371717000-22295-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu, 20 Jun 2013 16:30:00 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> This is debug info, should at least be pr_debug(), but given
> that this code is in upstream for two years, there is no
> need to keep this debugging printk any more, so just remove it.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied, thanks.
