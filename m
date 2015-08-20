From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Fix vxlan endianity issue
Date: Thu, 20 Aug 2015 14:08:20 -0700 (PDT)
Message-ID: <20150820.140820.1090416655815203705.davem@davemloft.net>
References: <1439968918-4608-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Rajesh.Borundia@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376AbbHTVIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 17:08:21 -0400
In-Reply-To: <1439968918-4608-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 19 Aug 2015 10:21:58 +0300

> Commit f34fa14cc033 ("bnx2x: Add vxlan RSS support") has introduced an
> endianity issue when passing the vxlan UDP port to the HW.
> 
> Reported-by: <fengguang.wu@intel.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied, thanks.
