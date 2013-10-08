From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pkt_sched: fq: fix non TCP flows pacing
Date: Tue, 08 Oct 2013 14:24:21 -0700
Message-ID: <1381267461.12191.59.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381182269.12191.27.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131008.165318.1392122841162708841.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sesse@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:55150 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755680Ab3JHVYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 17:24:23 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so9382599pdi.33
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 14:24:22 -0700 (PDT)
In-Reply-To: <20131008.165318.1392122841162708841.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-08 at 16:53 -0400, David Miller wrote:

> Is this meant for net or net-next?  It doesn't apply cleanly to the
> former.

Oh right, I need to respin for net tree, sorry for the confusion.
