From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] mvneta: drop redundant mac address check
Date: Tue, 29 Oct 2013 22:53:43 -0400 (EDT)
Message-ID: <20131029.225343.549663533284396310.davem@davemloft.net>
References: <1383088201-25136-1-git-send-email-luka@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: luka@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830Ab3J3Cxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 22:53:44 -0400
In-Reply-To: <1383088201-25136-1-git-send-email-luka@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luka Perkov <luka@openwrt.org>
Date: Wed, 30 Oct 2013 00:10:01 +0100

> Checking if MAC address is valid using is_valid_ether_addr() is already done in
> of_get_mac_address().
> 
> Signed-off-by: Luka Perkov <luka@openwrt.org>
> Acked-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

Applied.
