From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/3] net: macb: Disable half duplex gigabit on Zynq
Date: Fri, 22 May 2015 14:58:41 -0400 (EDT)
Message-ID: <20150522.145841.1742054345536765203.davem@davemloft.net>
References: <1432304531-23682-1-git-send-email-nathan.sullivan@ni.com>
	<1432304531-23682-2-git-send-email-nathan.sullivan@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nathan.sullivan@ni.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49749 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757225AbbEVS6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 14:58:43 -0400
In-Reply-To: <1432304531-23682-2-git-send-email-nathan.sullivan@ni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Sullivan <nathan.sullivan@ni.com>
Date: Fri, 22 May 2015 09:22:10 -0500

> According to the Zynq TRM, gigabit half duplex is not supported.  Add a
> new cap and compatible string so Zynq can avoid advertising that mode.
> 
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>

Applied.
