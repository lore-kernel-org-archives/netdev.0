From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v9] bfin_mac: convert bfin Ethernet driver to NAPI
 framework
Date: Thu, 24 Jul 2014 23:36:00 -0700 (PDT)
Message-ID: <20140724.233600.2088298487651174649.davem@davemloft.net>
References: <1406195579-13339-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	eric.dumazet@gmail.com, adi-buildroot-devel@lists.sourceforge.net,
	sonic.zhang@analog.com
To: sonic.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58834 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbaGYGgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 02:36:01 -0400
In-Reply-To: <1406195579-13339-1-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.adi@gmail.com>
Date: Thu, 24 Jul 2014 17:52:59 +0800

> From: Sonic Zhang <sonic.zhang@analog.com>
> 
> Ethernet RX DMA buffers are polled in NAPI work queue other than received
> directly in DMA RX interrupt handler.
> 
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>

Applied, thanks.
