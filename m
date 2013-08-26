From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 2/2] ipv6: Add support for IPsec virtual tunnel
 interfaces
Date: Mon, 26 Aug 2013 09:51:45 -0700
Message-ID: <1377535905.8828.122.camel@edumazet-glaptop>
References: <20130819062623.GN26773@secunet.com>
	 <20130819062730.GP26773@secunet.com>
	 <1377535058.11709.21.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:39130 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576Ab3HZQvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 12:51:47 -0400
Received: by mail-pb0-f53.google.com with SMTP id up15so3658634pbc.12
        for <netdev@vger.kernel.org>; Mon, 26 Aug 2013 09:51:46 -0700 (PDT)
In-Reply-To: <1377535058.11709.21.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-08-26 at 11:37 -0500, Dan Williams wrote:
> On Mon, 2013-08-19 at 08:27 +0200, Steffen Klassert wrote:
> > This patch adds IPv6  support for IPsec virtual tunnel interfaces
> > (vti). IPsec virtual tunnel interfaces provide a routable interface
> > for IPsec tunnel endpoints.
> 
> Are new ioctls for this kind of thing kosher?  Or should it be using
> netlink instead?

Please don't copy paste 1000 lines of patch, if you only had one
comment.
