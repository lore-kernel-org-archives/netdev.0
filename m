From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] ipv4: remove unused member in fib_table.
Date: Mon, 27 Apr 2009 02:35:39 -0700 (PDT)
Message-ID: <20090427.023539.182792249.davem@davemloft.net>
References: <eb3ff54b0904270222q72d9c108v73bc6e52b8dbba6e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39641
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752136AbZD0Jfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 05:35:46 -0400
In-Reply-To: <eb3ff54b0904270222q72d9c108v73bc6e52b8dbba6e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Mon, 27 Apr 2009 12:22:35 +0300

> This patch removes an unused parameter (tb_stamp) from fib_table structure in
>  include/net/ip_fib.h.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
