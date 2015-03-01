From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: bcmgenet and systemport statistics fixes
Date: Sun, 01 Mar 2015 14:02:45 -0500 (EST)
Message-ID: <20150301.140245.725941438349981429.davem@davemloft.net>
References: <1425175757-13378-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228AbbCATCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 14:02:46 -0500
In-Reply-To: <1425175757-13378-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat, 28 Feb 2015 18:09:15 -0800

> This two patches fix a similar problem in the GENET and SYSTEMPORT
> drivers for software maintained statistics used to track DMA mapping
> and SKB re-allocation failures.

Series applied, thanks Florian.
