From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: Fix to trim skb for padded vlan
 packets to workaround an ASIC Bug
Date: Wed, 27 Jun 2012 01:18:21 -0700 (PDT)
Message-ID: <20120627.011821.2058914958847860160.davem@davemloft.net>
References: <2931b75a-cf52-48cd-8639-388538fe9c26@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408Ab2F0ISV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 04:18:21 -0400
In-Reply-To: <2931b75a-cf52-48cd-8639-388538fe9c26@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Wed, 27 Jun 2012 11:34:29 +0530

> +	/* HW has a bug whicn considers padding bytes as legal
                        ^^^^^

Please fix that spelling error.
