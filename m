From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix rose.ko oops on unload
Date: Sun, 07 Oct 2007 23:44:33 -0700 (PDT)
Message-ID: <20071007.234433.21388460.davem@davemloft.net>
References: <20071003185413.GA16242@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org, pidoux@ccr.jussieu.fr
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50510
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752449AbXJHGoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 02:44:34 -0400
In-Reply-To: <20071003185413.GA16242@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 3 Oct 2007 22:54:13 +0400

> Quick'n'dirty fix to 100% oops on "rmmod rose". Do you want me to
> properly unwind everything before .24?

Patch applied, thanks Alexey.
