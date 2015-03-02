From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2015-03-02
Date: Mon, 02 Mar 2015 14:48:13 -0500 (EST)
Message-ID: <20150302.144813.2240523360918229942.davem@davemloft.net>
References: <20150302065354.GA3613@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754832AbbCBTsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 14:48:18 -0500
In-Reply-To: <20150302065354.GA3613@t440s.P-661HNU-F1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hedberg <johan.hedberg@gmail.com>
Date: Mon, 2 Mar 2015 08:53:54 +0200

> Here's the first bluetooth-next pull request targeting the 4.1 kernel:
> 
>  - ieee802154/6lowpan cleanups
>  - SCO routing to host interface support for the btmrvl driver
>  - AMP code cleanups
>  - Fixes to AMP HCI init sequence
>  - Refactoring of the HCI callback mechanism
>  - Added shutdown routine for Intel controllers in the btusb driver
>  - New config option to enable/disable Bluetooth debugfs information
>  - Fix for early data reception on L2CAP fixed channels
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks.
