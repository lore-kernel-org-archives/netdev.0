From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: net-next warning at kernel/softirq.c:159 local_bh_enable
Date: Fri, 6 Jul 2012 07:33:19 +0300
Message-ID: <CAJZOPZ+v5Si3LcHaHeBL7aaKPGYOD4bFrZ+gwNW6BhtMM3_h4A@mail.gmail.com>
References: <alpine.LRH.2.00.1207060616590.21283@ogerlitz.voltaire.com>
	<alpine.LRH.2.00.1207060716390.32599@ogerlitz.voltaire.com>
	<20120705.212042.1059058890336758924.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org,
	shlomop@mellanox.com, Erez Shitrit <erezsh@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:41199 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350Ab2GFEdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 00:33:20 -0400
Received: by gglu4 with SMTP id u4so8200742ggl.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 21:33:20 -0700 (PDT)
In-Reply-To: <20120705.212042.1059058890336758924.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 6, 2012 at 7:20 AM, David Miller <davem@davemloft.net> wrote:

> I sent you the infiniband patch necessary for this bug.

OK, tested with the patch, all is well, thanks!

Or.
