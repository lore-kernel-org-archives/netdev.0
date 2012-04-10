From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fix tcp_rcv_rtt_update() use of an unscaled RTT
 sample
Date: Tue, 10 Apr 2012 23:11:34 +0200
Message-ID: <1334092294.5300.614.camel@edumazet-glaptop>
References: <1334080760-968-1-git-send-email-ncardwell@google.com>
	 <20120410.144737.1047745906309843732.davem@davemloft.net>
	 <CAA93jw5opbBobzkgJ2diRPu2X0aKOsnF9hmcm_LfsLPipeAK7g@mail.gmail.com>
	 <20120410.170749.354288312321198124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dave.taht@gmail.com, ncardwell@google.com, netdev@vger.kernel.org,
	nanditad@google.com, ycheng@google.com, edumazet@google.com,
	therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:42994 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754967Ab2DJVLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 17:11:45 -0400
Received: by wibhq7 with SMTP id hq7so213957wib.1
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 14:11:44 -0700 (PDT)
In-Reply-To: <20120410.170749.354288312321198124.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 17:07 -0400, David Miller wrote:
> From: Dave Taht <dave.taht@gmail.com>
> Date: Tue, 10 Apr 2012 13:46:38 -0700
> 
> > awesome, is this needed in stable?
> 
> I have it queued up there already.
> 
> But you didn't need to write your email at all, you could
> have checked this yourself:
> 
> http://patchwork.ozlabs.org/user/bundle/2566/?state=*

Not sure this URL works (it doesnt for me)
