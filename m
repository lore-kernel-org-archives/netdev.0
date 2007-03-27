From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] [NET] fib_rules: Add no-operation action
Date: Mon, 26 Mar 2007 17:39:18 -0700 (PDT)
Message-ID: <20070326.173918.45514562.davem@davemloft.net>
References: <20070326235450.756924134@lsx.localdomain>
	<20070326235713.748511324@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33432
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933855AbXC0AjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 20:39:19 -0400
In-Reply-To: <20070326235713.748511324@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 27 Mar 2007 01:54:53 +0200

> The use of nop rules simplifies the usage of goto rules
> and adds more flexibility as they allow targets to remain
> while the actual content of the branches can change easly.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

This also looks good, applied to net-2.6.22
