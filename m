From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] bgmac: implement scatter/gather support
Date: Mon, 23 Mar 2015 16:56:56 -0400 (EDT)
Message-ID: <20150323.165656.1050386983774824930.davem@davemloft.net>
References: <1427110537-18091-1-git-send-email-nbd@openwrt.org>
	<1427110537-18091-3-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zajec5@gmail.com, hauke@hauke-m.de
To: nbd@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58242 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753218AbbCWU5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 16:57:00 -0400
In-Reply-To: <1427110537-18091-3-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Fietkau <nbd@openwrt.org>
Date: Mon, 23 Mar 2015 12:35:37 +0100

> Always use software checksumming, since the hardware does not have any
> checksum offload support.
> This significantly improves local TCP tx performance.
> 
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>

Applied.
