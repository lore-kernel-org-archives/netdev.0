From: David Miller <davem@davemloft.net>
Subject: Re: Gentle Guide to the Network Stack
Date: Thu, 19 Jun 2008 04:11:46 -0700 (PDT)
Message-ID: <20080619.041146.08784493.davem@davemloft.net>
References: <200806171105.23069.okir@lst.de>
	<d0383f90806190401n2c54bc5cl4e72dd65f6c64517@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: okir@lst.de, netdev@vger.kernel.org
To: ianbrn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59355
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756953AbYFSLLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 07:11:46 -0400
In-Reply-To: <d0383f90806190401n2c54bc5cl4e72dd65f6c64517@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ian Brown" <ianbrn@gmail.com>
Date: Thu, 19 Jun 2008 14:01:07 +0300

> I grepped for:
> struct sockalloc and  struct sock_alloc under the kernel tree (git 2.6
> netdev tree)
> and could not find such a thing.

He meant "struct socket_alloc"
