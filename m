From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix sctp breakage
Date: Wed, 18 Mar 2009 19:13:05 -0700 (PDT)
Message-ID: <20090318.191305.106590466.davem@davemloft.net>
References: <20090318031405.GX28946@ZenIV.linux.org.uk>
	<49C0E8FC.70706@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55808
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753636AbZCSCNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 22:13:18 -0400
In-Reply-To: <49C0E8FC.70706@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 18 Mar 2009 08:28:44 -0400

> Al Viro wrote:
> > broken by commit 5e739d1752aca4e8f3e794d431503bfca3162df4; AFAICS should
> > be -stable fodder as well...
> > 
> > Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
 ...
> ACK.  That wasn't a good way to write that increment.  I should have thought more
> about it, but at the time it seemed like a good idea...

Applied, thanks.
