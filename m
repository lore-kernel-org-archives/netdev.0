From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: Intialize link state to down before
 register_netdev
Date: Tue, 24 Mar 2015 18:03:08 -0400 (EDT)
Message-ID: <20150324.180308.1404318538705225775.davem@davemloft.net>
References: <1427231246-1782-1-git-send-email-cliff_clark@selinc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LeoLi@freescale.com, netdev@vger.kernel.org
To: cliff_clark@selinc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbbCXWDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:03:10 -0400
In-Reply-To: <1427231246-1782-1-git-send-email-cliff_clark@selinc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Cliff Clark" <cliff_clark@selinc.com>
Date: Tue, 24 Mar 2015 14:07:26 -0700

> From: Cliff Clark <cliff_clark@selinc.com>
> 
> ucc_geth was indicating link up after a port is administratively enabled even
> when nothing is plugged in.  This causes user-space tools to see a spurious link
> up the first time after boot.
> 
> Signed-off-by: Cliff Clark <cliff_clark@selinc.com>

Applied, thanks.
