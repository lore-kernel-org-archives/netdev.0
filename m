From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ifb: support more features
Date: Fri, 06 May 2016 17:21:43 -0700
Message-ID: <1462580503.13075.64.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462578076.13075.63.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33328 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759127AbcEGAVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 20:21:46 -0400
Received: by mail-pa0-f53.google.com with SMTP id xk12so52632053pac.0
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 17:21:46 -0700 (PDT)
In-Reply-To: <1462578076.13075.63.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-05-06 at 16:41 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> When using ifb+netem on ingress on SIT/IPIP/GRE traffic,
> GRO packets are not properly processed.
> 
> Segmentation should not be forced, as ifb is already adding
> quite a performance hit.

Please ignore, wrong version.

Will send a V2

Thanks.
