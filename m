From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] bgmac: fix descriptor frame start/end
 definitions
Date: Mon, 23 Mar 2015 16:56:43 -0400 (EDT)
Message-ID: <20150323.165643.1793038542557642338.davem@davemloft.net>
References: <1427110537-18091-1-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zajec5@gmail.com, hauke@hauke-m.de
To: nbd@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752557AbbCWU4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 16:56:46 -0400
In-Reply-To: <1427110537-18091-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Fietkau <nbd@openwrt.org>
Date: Mon, 23 Mar 2015 12:35:35 +0100

> The start-of-frame and end-of-frame bits were accidentally swapped.
> In the current code it does not make any difference, since they are
> always used together.
> 
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>

Applied.
