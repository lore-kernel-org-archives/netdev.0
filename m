From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2015-02-03
Date: Wed, 04 Feb 2015 13:56:57 -0800 (PST)
Message-ID: <20150204.135657.922951850114728698.davem@davemloft.net>
References: <20150203082123.GA13130@t440s.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38977 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932669AbbBDV46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 16:56:58 -0500
In-Reply-To: <20150203082123.GA13130@t440s.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hedberg <johan.hedberg@gmail.com>
Date: Tue, 3 Feb 2015 10:21:23 +0200

> Here's what's likely the last bluetooth-next pull request for 3.20.
> Notable changes include:
> 
>  - xHCI workaround + a new id for the ath3k driver
>  - Several new ids for the btusb driver
>  - Support for new Intel Bluetooth controllers
>  - Minor cleanups to ieee802154 code
>  - Nested sleep warning fix in socket accept() code path
>  - Fixes for Out of Band pairing handling
>  - Support for LE scan restarting for HCI_QUIRK_STRICT_DUPLICATE_FILTER
>  - Improvements to data we expose through debugfs
>  - Proper handling of Hardware Error HCI events
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
