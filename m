From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] bgmac: implement GRO and use build_skb
Date: Mon, 23 Mar 2015 16:56:50 -0400 (EDT)
Message-ID: <20150323.165650.1431421952003734212.davem@davemloft.net>
References: <1427110537-18091-1-git-send-email-nbd@openwrt.org>
	<1427110537-18091-2-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zajec5@gmail.com, hauke@hauke-m.de
To: nbd@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58237 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753177AbbCWU4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 16:56:53 -0400
In-Reply-To: <1427110537-18091-2-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Fietkau <nbd@openwrt.org>
Date: Mon, 23 Mar 2015 12:35:36 +0100

> This improves performance for routing and local rx
> 
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>

Applied.
