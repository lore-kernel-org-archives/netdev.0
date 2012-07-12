From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sch_sfb: Fix missing NULL check
Date: Thu, 12 Jul 2012 15:50:21 +0200
Message-ID: <1342101021.3265.8261.camel@edumazet-glaptop>
References: <20120712133847.18719.77998.stgit@localhost.localdomain>
	 <20120712.062553.947925376447776276.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:50390 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932387Ab2GLNu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 09:50:26 -0400
Received: by bkwj10 with SMTP id j10so2152429bkw.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 06:50:25 -0700 (PDT)
In-Reply-To: <20120712.062553.947925376447776276.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-12 at 06:25 -0700, David Miller wrote:
> From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Date: Thu, 12 Jul 2012 14:39:11 +0100
> 
> > Signed-off-by: Alan Cox <alna@linux.intel.com>
>                            ^^^^
> 
> I'm truly astonished that you type in signoffs by hand Alan.

Weel, I do the same ;)

Feel free to add my

Acked-by: Eric Dumazet <edumazet@google.com>
