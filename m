From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 08:43:34 -0800
Message-ID: <1447951414.22599.226.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
	 <20151119.104811.1447518072450380661.davem@davemloft.net>
	 <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151119.113336.1788979303067913870.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: zenczykowski@gmail.com, lorenzo@google.com,
	hannes@stressinduktion.org, stephen@networkplumber.org,
	netdev@vger.kernel.org, edumazet@google.com, ek@google.com,
	dtor@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34024 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755519AbbKSQng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 11:43:36 -0500
Received: by padhx2 with SMTP id hx2so85983634pad.1
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 08:43:36 -0800 (PST)
In-Reply-To: <20151119.113336.1788979303067913870.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-11-19 at 11:33 -0500, David Miller wrote:

> You cannot just say "I signoff on this, it's the only reasonable
> scheme, apply it."  That's not how we do things here.


I added my SOB because I effectively worked a lot on this patch.

Not because it is a sign of "This is the only way it can be done"

You already rejected some of my patches, obviously.
