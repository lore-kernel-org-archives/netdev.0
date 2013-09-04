From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: Fix little endian issues
Date: Wed, 04 Sep 2013 00:53:58 -0400 (EDT)
Message-ID: <20130904.005358.224572254007248399.davem@davemloft.net>
References: <20130903095532.507dcb44@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santil@linux.vnet.ibm.com, netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54666 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761368Ab3IDEx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 00:53:59 -0400
In-Reply-To: <20130903095532.507dcb44@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Tue, 3 Sep 2013 09:55:32 +1000

> 
> The hypervisor is big endian, so little endian kernel builds need
> to byteswap.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>

Applied.
