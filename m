From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/8] mISDN: Fixes and enhancements for the data
 channels
Date: Wed, 16 May 2012 15:28:17 -0400 (EDT)
Message-ID: <20120516.152817.1929889255651072708.davem@davemloft.net>
References: <1337161868-19399-1-git-send-email-kkeil@linux-pingi.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kkeil@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52649 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932210Ab2EPT2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 15:28:23 -0400
In-Reply-To: <1337161868-19399-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <kkeil@linux-pingi.de>
Date: Wed, 16 May 2012 11:51:00 +0200

> v2: All fixes from Dave Millers review
>    - comment format
>    - use bool type for boolean parameter
>    - use (var == CONSTANT)
> 
> This series improve the stability of streaming raw voice data when the
> system is under high load. With the fixes in place you can send and
> receive multiple faximilies (using SPANDSP) in parallel
> while compiling a kernel without a getting a transfer aborted.
> 
> for net-next

All applied to net-next.
