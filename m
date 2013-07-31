From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [Patch net-next] net: rename CONFIG_NET_LL_RX_POLL to CONFIG_NET_RX_BUSY_POLL
Date: Wed, 31 Jul 2013 16:35:11 +0300
Message-ID: <51F9128F.6030700@linux.intel.com>
References: <1375177125-7209-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42521 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759822Ab3GaNfQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 09:35:16 -0400
In-Reply-To: <1375177125-7209-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/07/2013 12:38, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> Eliezer renames several *ll_poll to *busy_poll, but forgets
> CONFIG_NET_LL_RX_POLL, so in case of confusion, rename it too.
> 
> Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Looks OK to me, but I'm not able to test it since I'm away on vacation.
If you can test it with the usual config options and allnoconfig, then I
have no objections to this patch.

If you want me to test it, that can only happen early next week.

Thanks,
Eliezer
