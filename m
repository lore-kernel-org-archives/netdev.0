From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] [4.5] NFC update
Date: Mon, 04 Jan 2016 21:48:46 -0500 (EST)
Message-ID: <20160104.214846.1353809846289549017.davem@davemloft.net>
References: <20151231192637.GA3247@zurbaran.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-nfc@lists.01.org
To: sameo@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753842AbcAECss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 21:48:48 -0500
In-Reply-To: <20151231192637.GA3247@zurbaran.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Samuel Ortiz <sameo@linux.intel.com>
Date: Thu, 31 Dec 2015 20:26:37 +0100

> This is the first NFC pull request for 4.5 and it brings:
> 
> - A new driver for the STMicroelectronics ST95HF NFC chipset.
>   The ST95HF is an NFC digital transceiver with an embedded analog
>   front-end and as such relies on the Linux NFC digital
>   implementation. This is the 3rd user of the NFC digital stack.
> 
> - ACPI support for the ST st-nci and st21nfca drivers.
> 
> - A small improvement for the nfcsim driver, as we can now tune
>   the Rx delay through sysfs.
> 
> - A bunch of minor cleanups and small fixes from Christophe Ricard,
>   for a few drivers and the NFC core code.

Pulled, thanks Samuel.
