From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2015-01-16
Date: Sun, 18 Jan 2015 00:25:55 -0500 (EST)
Message-ID: <20150118.002555.2085219089059787523.davem@davemloft.net>
References: <20150116113301.GA3818@t440s.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42361 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362AbbARFZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 00:25:56 -0500
In-Reply-To: <20150116113301.GA3818@t440s.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hedberg <johan.hedberg@gmail.com>
Date: Fri, 16 Jan 2015 13:33:01 +0200

> Here are some more bluetooth & ieee802154 patches intended for 3.20:
> 
>  - Refactoring & cleanups of ieee802154 & 6lowpan code
>  - Various fixes to the btmrvl driver
>  - Fixes for Bluetooth Low Energy Privacy feature handling
>  - Added build-time sanity checks for sockaddr sizes
>  - Fixes for Security Manager registration on LE-only controllers
>  - Refactoring of broken inquiry mode handling to a generic quirk
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
