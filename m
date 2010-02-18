From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 00/15] drivers/net: Use
 (pr|netdev|netif)_<level> macros
Date: Wed, 17 Feb 2010 18:20:33 -0800
Message-ID: <1266459633.8446.203.camel@Joe-Laptop.home>
References: <20100217.174615.133415843.davem@davemloft.net>
	 <1266458447.5719.44.camel@obelisk.thedillows.org>
	 <20100217.180122.195704088.davem@davemloft.net>
	 <20100217.180608.245806237.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org, netdev@vger.kernel.org, zambrano@broadcom.com,
	mchan@broadcom.com, eilong@broadcom.com, romieu@fr.zoreil.com,
	shemminger@linux-foundation.org, mcarlson@broadcom.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1077 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932259Ab0BRCUf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 21:20:35 -0500
In-Reply-To: <20100217.180608.245806237.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-02-17 at 18:06 -0800, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 17 Feb 2010 18:01:22 -0800 (PST)
> > From: David Dillow <dave@thedillows.org>
> > Date: Wed, 17 Feb 2010 21:00:47 -0500
> >> Have you pushed? I'd rather some of the typhoon ones not go in.
> > Why not?
> Please answer soon, I'm not going to wait around for you to "get
> around" to providing a reason for the typhoon changes to not go in.

Dave Dillow did give reasons for his dislike.
Perhaps passing in transit?

http://lkml.org/lkml/2010/2/17/458


