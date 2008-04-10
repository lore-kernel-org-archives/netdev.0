From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] socket: sk_filter minor cleanups
Date: Thu, 10 Apr 2008 01:39:12 -0700 (PDT)
Message-ID: <20080410.013912.139879174.davem@davemloft.net>
References: <20080401004708.009204033@vyatta.com>
	<20080401004724.454784783@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59665
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753675AbYDJIjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 04:39:11 -0400
In-Reply-To: <20080401004724.454784783@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 31 Mar 2008 17:47:09 -0700

> Some minor style cleanups:
>   * Move __KERNEL__ definitions to one place in filter.h
>   * Use const for sk_filter_len
>   * Line wrapping
>   * Put EXPORT_SYMBOL next to function definition
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-2.6.26, thanks!
