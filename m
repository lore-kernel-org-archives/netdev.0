From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2015-11-23
Date: Tue, 24 Nov 2015 16:23:01 -0500 (EST)
Message-ID: <20151124.162301.1296075877643077862.davem@davemloft.net>
References: <20151123135533.GA5257@t440s.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46090 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459AbbKXVXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 16:23:03 -0500
In-Reply-To: <20151123135533.GA5257@t440s.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hedberg <johan.hedberg@gmail.com>
Date: Mon, 23 Nov 2015 15:55:33 +0200

> Here's the first bluetooth-next pull request for the 4.5 kernel.
> 
>  - Add new Get Advertising Size Information management command
>  - Add support for new system note message type on monitor channel
>  - Refactor LE scan changes behind separate workqueue to avoid races
>  - Fix issue with privacy feature when powering on adapter
>  - Various minor fixes & cleanups here and there
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
