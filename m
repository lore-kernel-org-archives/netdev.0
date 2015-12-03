From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 0/3] bnxt_en: set mac address and uc_list bug
 fixes.
Date: Thu, 03 Dec 2015 15:10:39 -0500 (EST)
Message-ID: <20151203.151039.315892178286944602.davem@davemloft.net>
References: <1449039248-8745-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45455 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753271AbbLCUKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 15:10:40 -0500
In-Reply-To: <1449039248-8745-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>
Date: Wed, 2 Dec 2015 01:54:05 -0500

> Fix ndo_set_mac_address() for PF and VF.
> Re-apply uc_list after chip reset.
> 
> v2: Fix compile error if CONFIG_BNXT_SRIOV is not set.

Series applied, thanks Michael.
