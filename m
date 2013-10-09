From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] ipv6: make lookups simpler and faster
Date: Tue, 08 Oct 2013 21:26:19 -0700
Message-ID: <1381292779.4971.0.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380840149.19002.256.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131008.232125.1605815898898029345.davem@davemloft.net>
	 <20131009.000750.1849276529051781060.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:58813 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751909Ab3JIE0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 00:26:20 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so321233pde.9
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 21:26:20 -0700 (PDT)
In-Reply-To: <20131009.000750.1849276529051781060.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-09 at 00:07 -0400, David Miller wrote:
> Eric, I had to fix up l2tp_core.c to accomodate these changes due to
> something that came in during the net --> net-next merge, please
> double check my work.

Sure I am doing a full check, because I received a kbuild-bot report
right now anyway.

Thanks !
