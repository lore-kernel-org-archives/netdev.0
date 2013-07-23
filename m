From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Make devnet_rename_seq static
Date: Tue, 23 Jul 2013 07:17:15 -0700
Message-ID: <1374589035.1843.1.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1307231559570.4089@ionos.tec.linutronix.de>
	 <alpine.DEB.2.02.1307231612300.4089@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:47994 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932468Ab3GWORS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 10:17:18 -0400
Received: by mail-pb0-f43.google.com with SMTP id md12so8447049pbc.16
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 07:17:17 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1307231612300.4089@ionos.tec.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-23 at 16:13 +0200, Thomas Gleixner wrote:
> No users outside net/core/dev.c.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
