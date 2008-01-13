From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/9] printk related cleanups
Date: Sat, 12 Jan 2008 20:58:45 -0800 (PST)
Message-ID: <20080112.205845.90244939.davem@davemloft.net>
References: <20080112064513.803976049@linux-foundation.org>
	<20080112064646.507015655@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34530
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753381AbYAME6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 23:58:45 -0500
In-Reply-To: <20080112064646.507015655@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 11 Jan 2008 22:45:20 -0800

> printk related cleanups:
>  * Get rid of unused printk wrappers.
>  * Make bug checks into KERN_WARNING because KERN_DEBUG gets ignored
>  * Turn one cryptic old message into something real
>  * Make sure all messages have KERN_XXX

Applied, thanks.
