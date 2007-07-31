From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/unix/af_unix.c: make code static
Date: Mon, 30 Jul 2007 18:06:02 -0700 (PDT)
Message-ID: <20070730.180602.69409269.davem@davemloft.net>
References: <20070729145852.GA16817@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mszeredi@suse.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49866
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759422AbXGaBGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 21:06:11 -0400
In-Reply-To: <20070729145852.GA16817@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sun, 29 Jul 2007 16:58:52 +0200

> The following code can now become static:
> - struct unix_socket_table
> - unix_table_lock
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Also applied, thanks a lot.
