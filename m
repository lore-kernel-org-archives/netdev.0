From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fix tcp_rcv_rtt_update() use of an unscaled RTT
 sample
Date: Tue, 10 Apr 2012 23:22:11 +0200
Message-ID: <1334092931.5300.648.camel@edumazet-glaptop>
References: <CAA93jw5opbBobzkgJ2diRPu2X0aKOsnF9hmcm_LfsLPipeAK7g@mail.gmail.com>
	 <20120410.170749.354288312321198124.davem@davemloft.net>
	 <1334092294.5300.614.camel@edumazet-glaptop>
	 <20120410.171637.622088330832657275.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dave.taht@gmail.com, ncardwell@google.com, netdev@vger.kernel.org,
	nanditad@google.com, ycheng@google.com, edumazet@google.com,
	therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:37847 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754664Ab2DJVWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 17:22:15 -0400
Received: by wejx9 with SMTP id x9so154692wej.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 14:22:14 -0700 (PDT)
In-Reply-To: <20120410.171637.622088330832657275.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 17:16 -0400, David Miller wrote:

> Sorry, that's my private URL and only works if you're logged
> in as me :-)  This one is better:
> 
> http://patchwork.ozlabs.org/bundle/davem/stable/?state=*

Thanks, added to my bookmarks ;)
