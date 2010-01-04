From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Test off by one in sh_eth_reset()
Date: Sun, 03 Jan 2010 21:43:44 -0800 (PST)
Message-ID: <20100103.214344.55841020.davem@davemloft.net>
References: <4B3B3CF1.6060107@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51837
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753229Ab0ADFnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 00:43:40 -0500
In-Reply-To: <4B3B3CF1.6060107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Wed, 30 Dec 2009 12:43:45 +0100

> If no break occurred, cnt reaches 0 after the loop.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.
