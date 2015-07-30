From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2015-07-30
Date: Thu, 30 Jul 2015 16:17:23 -0700 (PDT)
Message-ID: <20150730.161723.780687374288228317.davem@davemloft.net>
References: <20150730173448.GA13424@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482AbbG3XRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 19:17:24 -0400
In-Reply-To: <20150730173448.GA13424@t440s.P-661HNU-F1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hedberg <johan.hedberg@gmail.com>
Date: Thu, 30 Jul 2015 20:34:48 +0300

> Here's a set of Bluetooth & 802.15.4 patches intended for the 4.3 kernel.
> 
>  - Cleanups & fixes to mac802154
>  - Refactoring of Intel Bluetooth HCI driver
>  - Various coding style fixes to Bluetooth HCI drivers
>  - Support for Intel Lightning Peak Bluetooth devices
>  - Generic class code in interface descriptor in btusb to match more HW
>  - Refactoring of Bluetooth HS code together with a new config option
>  - Support for BCM4330B1 Broadcom UART controller
> 
> Let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
