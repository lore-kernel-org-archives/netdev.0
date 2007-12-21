From: David Miller <davem@davemloft.net>
Subject: Re: [TCP] tcp_write_timeout.c cleanup
Date: Fri, 21 Dec 2007 01:51:23 -0800 (PST)
Message-ID: <20071221.015123.119238012.davem@davemloft.net>
References: <476B5581.6040603@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49247
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752078AbXLUJvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 04:51:24 -0500
In-Reply-To: <476B5581.6040603@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 21 Dec 2007 06:56:17 +0100

> Before submiting a patch to change a divide to a right shift, I felt
> necessary to create a helper function tcp_mtu_probing() to reduce length of 
> lines exceeding 100 chars in tcp_write_timeout().
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Thanks for not mixing code cleanups with functional changes,
it makes my life so much easier and make me so much want to
review and apply your patches.
