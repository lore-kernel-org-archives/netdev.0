From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] net: broadcom MDIO support for broken
 turn-around
Date: Thu, 11 Jun 2015 00:32:41 -0700 (PDT)
Message-ID: <20150611.003241.1247517255112645282.davem@davemloft.net>
References: <1433964251-17338-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175AbbFKHcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 03:32:42 -0400
In-Reply-To: <1433964251-17338-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 10 Jun 2015 12:24:09 -0700

> These two patches update the GENET and UniMAC MDIO controllers to deal with
> PHYs that are known to have a broken turn-around bug (e.g: BCM53125 and others)
> 
> This utilizes the infrastructure that code recently added to do that in 'net-next'.
> 
> Note that the changes look nearly identical and I will try to address the MDIO
> code duplication between GENET and UniMAC in a future patch series.

Ok, series applied, thanks Florian.
