From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: bcmgenet: EEE support
Date: Wed, 26 Nov 2014 15:09:06 -0500 (EST)
Message-ID: <20141126.150906.1197410224109013939.davem@davemloft.net>
References: <1416978996-24808-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbaKZUJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 15:09:11 -0500
In-Reply-To: <1416978996-24808-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 25 Nov 2014 21:16:33 -0800

> This patch series add EEE support to the Broadcom GENET driver, first patch
> basically adds register definitions for the hardware, the second patch does the
> actual implementation and hooks the {get,set}_eee ethtool callbacks, the last
> patch adds auto-negotiation restart capability.

Series applied, thanks.
