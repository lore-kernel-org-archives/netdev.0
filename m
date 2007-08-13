From: Michael Trimarchi <trimarchi@gandalf.sssup.it>
Subject: Re: dm9000: add set_mac_address()
Date: Mon, 13 Aug 2007 09:24:37 +0200
Message-ID: <46C00735.8050405@gandalf.sssup.it>
References: <20070812192741.GB27490@gandalf.sssup.it> <46BF9304.9080709@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms01.sssup.it ([193.205.80.99]:53672 "EHLO sssup.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S941540AbXHMHYp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 03:24:45 -0400
In-Reply-To: <46BF9304.9080709@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>
>     probe time:
>     read MAC address from SROM
>
>     dev open (interface up):
>     write dev->dev_addr[] to RX filter (or identity) registers
>
> EEPROM update support is available separately, via an ethtool sub-ioctl.
>
>     Jeff
>
ok

regards
michael

