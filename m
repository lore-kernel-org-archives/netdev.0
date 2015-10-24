From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnxt_en: Fix compile errors when
 CONFIG_BNXT_SRIOV is not set.
Date: Fri, 23 Oct 2015 17:47:31 -0700 (PDT)
Message-ID: <20151023.174731.1157576872224918662.davem@davemloft.net>
References: <1445627179-9971-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jim.hull@hpe.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbbJXAa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 20:30:59 -0400
In-Reply-To: <1445627179-9971-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>
Date: Fri, 23 Oct 2015 15:06:19 -0400

> struct bnxt_pf_info needs to be always defined.  Move bnxt_update_vf_mac()
> to bnxt_sriov.c and add some missing #ifdef CONFIG_BNXT_SRIOV.
> 
> Reported-by: Jim Hull <jim.hull@hpe.com>
> Tested-by: Jim Hull <jim.hull@hpe.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
