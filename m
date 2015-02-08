From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: dsa: bcm_sf2: GPHY power down
Date: Sat, 07 Feb 2015 22:39:04 -0800 (PST)
Message-ID: <20150207.223904.1497238744371124434.davem@davemloft.net>
References: <1423165242-6042-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47138 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbbBHGjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 01:39:05 -0500
In-Reply-To: <1423165242-6042-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu,  5 Feb 2015 11:40:40 -0800

> This patch series implement GPHY power up and down in the SF2 switch
> driver in order to conserve power whenever possible (e.g: port is brought
> down or unused during Wake-on-LAN).

Applied, thanks Florian.
