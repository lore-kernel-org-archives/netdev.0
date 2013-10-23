From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v5 0/5] xen-netback: IPv6 offload support
Date: Wed, 23 Oct 2013 13:39:55 +0100
Message-ID: <20131023123955.GA17440@zion.uk.xensource.com>
References: <1381942232-26268-1-git-send-email-paul.durrant@citrix.com>
 <20131017.153622.88986190427961174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <paul.durrant@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <wei.liu2@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:16451 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753386Ab3JWMj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 08:39:57 -0400
Content-Disposition: inline
In-Reply-To: <20131017.153622.88986190427961174.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 17, 2013 at 03:36:22PM -0400, David Miller wrote:
> From: Paul Durrant <paul.durrant@citrix.com>
> Date: Wed, 16 Oct 2013 17:50:27 +0100
> 
> > This patch series adds support for checksum and large packet offloads into
> > xen-netback.
> > Testing has mainly been done using the Microsoft network hardware
> > certification suite running in Server 2008R2 VMs with Citrix PV frontends.
> 
> Series applied, thanks.

Paul, now that this series is applied to net-next, could you send a
patch to Xen's master copy netif.h?

Thanks
Wei.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
