From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Add missing HSI for big-endian machines
Date: Thu, 18 Feb 2016 23:33:50 -0500 (EST)
Message-ID: <20160218.233350.2252131631349428866.davem@davemloft.net>
References: <1455707714-5262-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54001 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756908AbcBSEd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 23:33:56 -0500
In-Reply-To: <1455707714-5262-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 17 Feb 2016 13:15:14 +0200

> Commit e5d3a51cefbb "bnx2x: extend DCBx support" was missing HSI changes
> for big-endian machine, breaking compilation on such platforms.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied.
