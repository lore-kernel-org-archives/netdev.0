From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 3/4] xen-netback: pass hash value to the frontend
Date: Tue, 10 May 2016 14:29:21 +0100
Message-ID: <20160510132921.GE12241@citrix.com>
References: <1462447170-1815-1-git-send-email-paul.durrant@citrix.com>
 <1462447170-1815-4-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:30188 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbcEJN31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 09:29:27 -0400
Content-Disposition: inline
In-Reply-To: <1462447170-1815-4-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2016 at 12:19:29PM +0100, Paul Durrant wrote:
> My recent patch to include/xen/interface/io/netif.h defines a new extra
> info type that can be used to pass hash values between backend and guest
> frontend.
> 
> This patch adds code to xen-netback to pass hash values calculated for
> guest receive-side packets (i.e. netback transmit side) to the frontend.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>
