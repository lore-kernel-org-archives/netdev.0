From: David Miller <davem@davemloft.net>
Subject: Re: [net: stable request] dst->obsolete handling in 2.6.32-stable
 kernels - invalid cached routes never invalidated
Date: Sat, 13 Oct 2012 18:26:05 -0400 (EDT)
Message-ID: <20121013.182605.2130022796761802097.davem@davemloft.net>
References: <20121013175240.GK5453@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60030 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751648Ab2JMW0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2012 18:26:07 -0400
In-Reply-To: <20121013175240.GK5453@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Sat, 13 Oct 2012 13:52:40 -0400

> To fix this bug, would it be possible to get commit 
> d11a4dc18bf41719c9f0d7ed494d295dd2973b92 queued up for 2.6.32-stable?  
> Setting dst.obsolete to -1 seems to be the least invasive way of fixing 
> this bug.  Thanks a bunch,

I do not manage, nor care, about 2.6.32-stable kernels.

I'm going back as far as 3.0.x at this point, so other people
have to take care of the older stuff.
