From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth 2015-11-05
Date: Thu, 05 Nov 2015 11:38:52 -0500 (EST)
Message-ID: <20151105.113852.1180740055846209439.davem@davemloft.net>
References: <20151105061929.GA599@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36563 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031640AbbKEQiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 11:38:55 -0500
In-Reply-To: <20151105061929.GA599@t440s.P-661HNU-F1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hedberg <johan.hedberg@gmail.com>
Date: Thu, 5 Nov 2015 08:19:29 +0200

> The following set of Bluetooth patches would be good to get into 4.4-rc1
> if possible:
> 
>  - Fix for missing LE CoC parameter validity checks
>  - Fix for potential deadlock in btusb
>  - Fix for issuing unsupported commands during HCI init
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
