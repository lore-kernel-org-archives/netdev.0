From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 9p: fix endian issues [attempt 3]
Date: Fri, 06 Feb 2009 22:07:52 -0800 (PST)
Message-ID: <20090206.220752.131865996.davem@davemloft.net>
References: <1233957953-22830-1-git-send-email-ericvh@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ericvh@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35955
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751083AbZBGGHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 01:07:55 -0500
In-Reply-To: <1233957953-22830-1-git-send-email-ericvh@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ericvh@gmail.com
Date: Fri,  6 Feb 2009 16:05:53 -0600

> When the changes were done to the protocol last release, some endian
> bugs crept in.  This patch fixes those endian problems and has been
> verified to run on 32/64 bit and x86/ppc architectures.
> 
> This version of the patch incorporates the correct annotations
> for endian variables.
> 
> Signed-off-by: Eric Van Hensbergen <ericvh@gmail.com>

Patch applied, thanks Eric.
