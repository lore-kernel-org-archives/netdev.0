From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netback: remove dead code
Date: Mon, 6 May 2013 17:22:12 +0100
Message-ID: <20130506162211.GE32539@zion.uk.xensource.com>
References: <1367854820-4129-1-git-send-email-wei.liu2@citrix.com>
 <20130506161033.GD32539@zion.uk.xensource.com>
 <20130506.121722.2064597841318034990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:8683 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754718Ab3EFQWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 May 2013 12:22:13 -0400
Content-Disposition: inline
In-Reply-To: <20130506.121722.2064597841318034990.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 06, 2013 at 05:17:22PM +0100, David Miller wrote:
> From: Wei Liu <wei.liu2@citrix.com>
> Date: Mon, 6 May 2013 17:10:33 +0100
> 
> > On Mon, May 06, 2013 at 04:40:20PM +0100, Wei Liu wrote:
> >> The array mmap_pages is never touched in the initialization function. This is
> >> remnant of mapping mechanism, which does exist upstream.
> >> 
> > 
> > This patch targets net-next.
> 
> http://marc.info/?l=linux-netdev&m=136730964130303&w=2
> --

Got it.


Wei.

> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
