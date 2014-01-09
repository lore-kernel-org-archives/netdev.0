From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2 2/3] xen-netback: use new skb_checksum_setup
 function
Date: Thu, 9 Jan 2014 12:26:48 +0000
Message-ID: <20140109122648.GB12164@zion.uk.xensource.com>
References: <1389261768-30606-1-git-send-email-paul.durrant@citrix.com>
 <1389261768-30606-3-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:6518 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751060AbaAIM0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:26:50 -0500
Content-Disposition: inline
In-Reply-To: <1389261768-30606-3-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 09, 2014 at 10:02:47AM +0000, Paul Durrant wrote:
> Use skb_checksum_setup to set up partial checksum offsets rather
> then a private implementation.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

If your change to core driver goes in then:

Acked-by: Wei Liu <wei.liu2@citrix.com>

Thanks
Wei.
