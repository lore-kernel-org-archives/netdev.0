From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/3] net: bcmgenet & systemport fixes
Date: Fri, 10 Oct 2014 15:39:43 -0400 (EDT)
Message-ID: <20141010.153943.1739641415448501255.davem@davemloft.net>
References: <1412963514-7718-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56450 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755156AbaJJTjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 15:39:45 -0400
In-Reply-To: <1412963514-7718-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 10 Oct 2014 10:51:51 -0700

> This patch series fixes an off-by-one error introduced during a previous
> change, and the two other fixes fix a wake depth imbalance situation for
> the Wake-on-LAN interrupt line.

Series applied, thanks Florian.
