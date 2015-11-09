From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] [4.4] NFC fixes
Date: Sun, 08 Nov 2015 20:48:37 -0500 (EST)
Message-ID: <20151108.204837.780942913213576696.davem@davemloft.net>
References: <20151109010231.GA31406@zurbaran.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-nfc@lists.01.org
To: sameo@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbbKIB4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 20:56:02 -0500
In-Reply-To: <20151109010231.GA31406@zurbaran.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Samuel Ortiz <sameo@linux.intel.com>
Date: Mon, 9 Nov 2015 02:02:31 +0100

> This is the 1st NFC fixes pull request for 4.4.
> 
> It includes bug fixes and one fix for a build failure, all of them
> introduced with the first NFC pull request for 4.4.
> 
> We have:
> 
> - Fix nfcmrvl SPI driver potential build error due to a broken Kconfig
>   dependency.
> - A few fixes for the firmware download implementation for the nfcmrvl
>   UART driver.
> - A GPIO allocation leak for the nfcmrvl driver.
> - One code simplification for the nfcmrvl DT handling.

Pulled, thanks Samuel.
