From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Make devnet_rename_seq static
Date: Tue, 23 Jul 2013 07:12:51 -0700
Message-ID: <1374588771.1843.0.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1307231559570.4089@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:65033 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932442Ab3GWOMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 10:12:54 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so8409122pbb.36
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 07:12:53 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1307231559570.4089@ionos.tec.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-23 at 16:05 +0200, Thomas Gleixner wrote:
> No users outside net/core/dev.c.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Seems you need more coffee than I do ;)
