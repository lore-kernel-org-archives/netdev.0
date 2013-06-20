From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH nf-next] netfilter: xt_socket: add XT_SOCKET_NOWILDCARD
 flag
Date: Thu, 20 Jun 2013 03:19:20 -0700
Message-ID: <1371723560.3252.399.camel@edumazet-glaptop>
References: <1370300249.24311.190.camel@edumazet-glaptop>
	 <1371717515.3252.392.camel@edumazet-glaptop>
	 <20130620095500.GB698@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:47175 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964966Ab3FTKTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 06:19:25 -0400
In-Reply-To: <20130620095500.GB698@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-20 at 11:55 +0200, Pablo Neira Ayuso wrote:

> user-space part is missing (or at least I didn't manage to find the
> patch).

OK, I'll send the user-space, I was not sure if you wanted too.

(Stephen always want kernel part being applied before iproute2 changes)

> 
> We've been adding new revision for such a changes. I know it's a bit
> too much, but we want to make sure that a user does not set this
> option from user-space and it's silently ignored by iptables.

No problem, will send a v2.

Thanks
