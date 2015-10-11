From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2015-10-08
Date: Sun, 11 Oct 2015 05:20:17 -0700 (PDT)
Message-ID: <20151011.052017.2010610253690558091.davem@davemloft.net>
References: <20151008140058.GA21971@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57060 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbbJKMEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 08:04:23 -0400
In-Reply-To: <20151008140058.GA21971@t440s.P-661HNU-F1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hedberg <johan.hedberg@gmail.com>
Date: Thu, 8 Oct 2015 17:00:58 +0300

> Here's another set of Bluetooth & 802.15.4 patches for the 4.4 kernel.
> 
> 802.15.4:
>  - Many improvements & fixes to the mrf24j40 driver
>  - Fixes and cleanups to nl802154, mac802154 & ieee802154 code
> 
> Bluetooth:
>  - New chipset support in btmrvl driver
>  - Fixes & cleanups to btbcm, btmrvl, bpa10x & btintel drivers
>  - Support for vendor specific diagnostic data through common API
>  - Cleanups to the 6lowpan code
>  - New events & message types for monitor channel
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
