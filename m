From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] b44: add calls to phy_{start,stop}
Date: Sun, 02 Mar 2014 19:05:55 -0500 (EST)
Message-ID: <20140302.190555.1021550952987592721.davem@davemloft.net>
References: <1393777774-7400-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46546 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783AbaCCAF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 19:05:57 -0500
In-Reply-To: <1393777774-7400-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Sun,  2 Mar 2014 17:29:33 +0100

> When support for external phys was added to b44, the calls to start and
> stop the phy were missing in the mac driver. This adds the calls to
> phy_start() and phy_stop().
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Applied.
