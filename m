From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 ] ipv4: remove ip_mc_drop_socket()
 declaration from af_inet.c.
Date: Wed, 03 Jun 2009 21:43:34 -0700 (PDT)
Message-ID: <20090603.214334.45408930.davem@davemloft.net>
References: <eb3ff54b0906031347l13de166du58abb40d74e931b6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45139
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751152AbZFDEnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 00:43:33 -0400
In-Reply-To: <eb3ff54b0906031347l13de166du58abb40d74e931b6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Wed, 3 Jun 2009 23:47:04 +0300

> ip_mc_drop_socket() method is declared in linux/igmp.h, which
> is included anyhow in af_inet.c. So there is no need for this declaration.
> This patch removes it from af_inet.c.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks!
