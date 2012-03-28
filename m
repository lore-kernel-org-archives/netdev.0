From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: remove useless update for flag parameter in
 tcp_enter_frto_loss()
Date: Wed, 28 Mar 2012 09:34:40 +0200
Message-ID: <1332920080.3547.42.camel@edumazet-glaptop>
References: <4F729235.8040706@gmail.com>
	 <CADVnQymQaCSKx0aRda6OiP=t2OToxHmvjXjYvTdxsq7oFE3DTg@mail.gmail.com>
	 <4F72B589.5060903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>, netdev@vger.kernel.org
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:46583 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754584Ab2C1Her (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 03:34:47 -0400
Received: by eekc41 with SMTP id c41so167150eek.19
        for <netdev@vger.kernel.org>; Wed, 28 Mar 2012 00:34:45 -0700 (PDT)
In-Reply-To: <4F72B589.5060903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-03-28 at 14:54 +0800, Li Yu wrote:

> Sorry for spent time on this, it it account for F-RTO retransmitted
> segment here.

I dont believe its waste of time having several eyes on this code.

Thanks
