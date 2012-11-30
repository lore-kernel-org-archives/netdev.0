From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V2 1/9] net: frag evictor, avoid killing warm
 frag queues
Date: Fri, 30 Nov 2012 14:25:19 -0800
Message-ID: <1354314319.20109.179.camel@edumazet-glaptop>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161052.17754.85017.stgit@dragon>
	 <20121129.124427.1093031685966728935.davem@davemloft.net>
	 <1354227470.11754.348.camel@localhost>
	 <1354230100.3299.40.camel@edumazet-glaptop>
	 <1354269846.11754.381.camel@localhost>
	 <1354287134.3299.67.camel@edumazet-glaptop>
	 <1354290335.11754.447.camel@localhost>
	 <1354293469.3299.81.camel@edumazet-glaptop>
	 <1354311437.11754.459.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org, pablo@netfilter.org, tgraf@suug.ch,
	amwang@redhat.com, kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:50005 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753987Ab2K3WZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 17:25:21 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so737256pbc.19
        for <netdev@vger.kernel.org>; Fri, 30 Nov 2012 14:25:21 -0800 (PST)
In-Reply-To: <1354311437.11754.459.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-30 at 22:37 +0100, Jesper Dangaard Brouer wrote:

> 
> Come on Eric, you are smart than this.  When will you realize, that
> dropping partly completed fragment queue are bad for performance? (And
> thus a bad algorithmic choice in the evictor)

Sorry I must be dumb, so I'll stop commenting.
