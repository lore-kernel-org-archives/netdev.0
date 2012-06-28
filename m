From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] xfrm_user: Propagate netlink error codes properly.
Date: Thu, 28 Jun 2012 03:40:30 -0400
Message-ID: <20120628074030.GF31808@canuck.infradead.org>
References: <20120627.215728.137770920620706227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:39403 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054Ab2F1Hkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 03:40:32 -0400
Content-Disposition: inline
In-Reply-To: <20120627.215728.137770920620706227.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 27, 2012 at 09:57:28PM -0700, David Miller wrote:
> 
> Instead of using a fixed value of "-1" or "-EMSGSIZE", propagate what
> the nla_*() interfaces actually return.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Reviewed-by: Thomas Graf <tgraf@suug.ch>
