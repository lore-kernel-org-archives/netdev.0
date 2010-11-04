From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netlink: Make nlmsg_find_attr take a const
 nlmsghdr*.
Date: Thu, 04 Nov 2010 12:26:44 -0700 (PDT)
Message-ID: <20101104.122644.59664739.davem@davemloft.net>
References: <1288838141-17871-1-git-send-email-nelhage@ksplice.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nelhage@ksplice.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56775
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751277Ab0KDT0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Nov 2010 15:26:20 -0400
In-Reply-To: <1288838141-17871-1-git-send-email-nelhage@ksplice.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nelson Elhage <nelhage@ksplice.com>
Date: Wed,  3 Nov 2010 22:35:40 -0400

> This will let us use it on a nlmsghdr stored inside a netlink_callback.
> 
> Signed-off-by: Nelson Elhage <nelhage@ksplice.com>

Applied.
