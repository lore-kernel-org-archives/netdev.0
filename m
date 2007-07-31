From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.23-rc1] PPPOL2TP: Add CONFIG_INET Kconfig dependency
Date: Mon, 30 Jul 2007 18:52:03 -0700 (PDT)
Message-ID: <20070730.185203.102465237.davem@davemloft.net>
References: <200707301205.l6UC5dmR026629@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, toralf.foerster@gmx.de
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42242
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758511AbXGaBwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 21:52:04 -0400
In-Reply-To: <200707301205.l6UC5dmR026629@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Mon, 30 Jul 2007 13:05:39 +0100

> [PPPOL2TP]: Add CONFIG_INET Kconfig dependency.
> 
> PPPOL2TP uses UDP so it obviously depends on CONFIG_INET. 
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>

Fair enough, applied, thanks James.
