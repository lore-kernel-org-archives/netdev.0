From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qed*: Add support for ethtool link_ksettings
 callbacks.
Date: Wed, 10 Aug 2016 17:36:22 -0700 (PDT)
Message-ID: <20160810.173622.2233111036337494546.davem@davemloft.net>
References: <1470729083-12840-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@qlogic.com
To: sudarsana.kalluru@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42178 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279AbcHKAgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 20:36:53 -0400
In-Reply-To: <1470729083-12840-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Date: Tue, 9 Aug 2016 03:51:23 -0400

> This patch adds the driver implementation for ethtool link_ksettings
> callbacks. qed driver now defines/uses the qed specific masks for
> representing link capability values. qede driver maps these values to
> to new link modes defined by the kernel implementation of link_ksettings.
> 
> Please consider applying this to 'net-next' branch.
> 
> Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied, thanks.
