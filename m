From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip6ip6: autoload ip6 tunnel
Date: Thu, 10 Mar 2011 14:00:36 -0800 (PST)
Message-ID: <20110310.140036.71099549.davem@davemloft.net>
References: <20110310134319.25b1b901@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, segoon@openwall.com, mjt@tls.msk.ru,
	kees.cook@canonical.com, jmorris@namei.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49709
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753116Ab1CJV76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 16:59:58 -0500
In-Reply-To: <20110310134319.25b1b901@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 10 Mar 2011 13:43:19 -0800

> Add necessary alias to autoload ip6ip6 tunnel module.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> Patch is against 2.6.38-rc7 (not net-next).

Yep, understood.  I'll do a merge then apply this, thanks Stephen!
