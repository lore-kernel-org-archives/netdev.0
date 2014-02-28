From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V5 net-next 2/5] xen-netback: Add support for multiple
 queues
Date: Fri, 28 Feb 2014 15:13:01 +0000
Message-ID: <20140228151301.GO16241@zion.uk.xensource.com>
References: <1393252387-17496-1-git-send-email-andrew.bennieston@citrix.com>
 <1393252387-17496-3-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:26738 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751910AbaB1PNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 10:13:02 -0500
Content-Disposition: inline
In-Reply-To: <1393252387-17496-3-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 24, 2014 at 02:33:04PM +0000, Andrew J. Bennieston wrote:
> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
> Builds on the refactoring of the previous patch to implement multiple
> queues between xen-netfront and xen-netback.
> 
> Writes the maximum supported number of queues into XenStore, and reads
> the values written by the frontend to determine how many queues to use.
> 
> Ring references and event channels are read from XenStore on a per-queue
> basis and rings are connected accordingly.
> 
> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

Thanks
Wei.
