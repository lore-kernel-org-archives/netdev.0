From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] doc: document MSG_ZEROCOPY
Date: Fri, 1 Sep 2017 14:44:24 +0200
Message-ID: <20170901144424.72f9c9e9@redhat.com>
References: <20170831210013.85220-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50608 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751778AbdIAMob (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 08:44:31 -0400
In-Reply-To: <20170831210013.85220-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Aug 2017 17:00:13 -0400
Willem de Bruijn <willemdebruijn.kernel@gmail.com> wrote:

> +More Info
> +---------
> +
> +Much of this document was derived from a longer paper presented at
> +netdev 2.1. For more in-depth information see that paper and talk,
> +the excellent reporting over at LWN.net or read the original code.
> +
> +  paper, slides, video
> +    https://netdevconf.org/2.1/session.html?debruijn
> +
> +  LWN article
> +    https://lwn.net/Articles/726917/
> +
> +  patchset
> +    [PATCH net-next v4 0/9] socket sendmsg MSG_ZEROCOPY
> +    https://lwn.net/Articles/730010/
> +    https://www.spinics.net/lists/netdev/msg447552.html

IMHO I think it would be better to use the type links also used in the
git log.  If you look at the kernel git log, then the "Link:" tag have
the form: http://lkml.kernel.org/r/
And you can simply append the "Message-Id:" email header.

In this case the link would be:
  http://lkml.kernel.org/r/20170803202945.70750-1-willemdebruijn.kernel@gmail.com
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
