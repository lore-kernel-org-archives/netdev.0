From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] net: bgmac: Misc improvements
Date: Thu, 09 Jun 2016 23:37:37 -0700 (PDT)
Message-ID: <20160609.233737.1585934679357918917.davem@davemloft.net>
References: <1465337175-22368-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk, zajec5@gmail.com,
	hauke@hauke-m.de, jon.mason@broadcom.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54097 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178AbcFJGhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 02:37:38 -0400
In-Reply-To: <1465337175-22368-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue,  7 Jun 2016 15:06:12 -0700

> Hi David, Rafal, Hauke, Felix,
> 
> This patch series add minor changes to the bgmac driver:
> 
> - properly bind net_device with its backing device structure such that
>   we can locate the device using common helper functions
> 
> - add support for ethtool statistics reading the HW MIB counters which
>   is useful for debugging
> 
> - add netdev statistics throughout the TX/RX path to know what is going on

Series applied, thanks.
