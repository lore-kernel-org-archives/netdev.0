From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 0/4] DSA: Fix checkpatch.pl output for DSA drivers
Date: Thu, 10 Jan 2013 00:04:48 -0800 (PST)
Message-ID: <20130110.000448.500364342701356675.davem@davemloft.net>
References: <1357697156-5767-1-git-send-email-barry@grussling.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: barry@grussling.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53509 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932564Ab3AJIEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 03:04:49 -0500
In-Reply-To: <1357697156-5767-1-git-send-email-barry@grussling.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barry Grussling <barry@grussling.com>
Date: Tue,  8 Jan 2013 18:05:52 -0800

> This set of patches performs routine maintenance on the DSA drivers
> by removing all checkpatch.pl errors.
> 
> These patches do the following things:
>  * Switch to network-style comments
>  * Convert msleep calls to timeout/usleep_range calls
>  * Convert printk calls to netdev_info calls
>  * Fix whitespace issues

All applied, thanks.
