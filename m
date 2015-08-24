From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] [4.3] NFC update
Date: Sun, 23 Aug 2015 20:43:32 -0700 (PDT)
Message-ID: <20150823.204332.939189774876135108.davem@davemloft.net>
References: <20150820233908.GA1988@zurbaran.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-nfc@lists.01.org, netdev@vger.kernel.org
To: sameo@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48033 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753738AbbHXDnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 23:43:33 -0400
In-Reply-To: <20150820233908.GA1988@zurbaran.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Samuel Ortiz <sameo@linux.intel.com>
Date: Fri, 21 Aug 2015 01:39:08 +0200

> This is the NFC pull request for 4.3.
> With this one we have:
> 
> - A new driver for Samsung's S3FWRN5 NFC chipset. In order to
>   properly support this driver, a few NCI core routines needed
>   to be exported. Future drivers like Intel's Fields Peak will
>   benefit from this.
> 
> - SPI support as a physical transport for STM st21nfcb.
> 
> - An additional netlink API for sending replies back to userspace
>   from vendor commands.
> 
> - 2 small fixes for TI's trf7970a
> 
> - A few st-nci fixes.

Pulled, thanks Samuel.
