From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v4 2/4] xen-netback: add control protocol
 implementation
Date: Fri, 13 May 2016 12:20:11 +0100
Message-ID: <20160513112011.GB5442@citrix.com>
References: <1463128649-20832-1-git-send-email-paul.durrant@citrix.com>
 <1463128649-20832-3-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:39624 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbcEMLUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 07:20:18 -0400
Content-Disposition: inline
In-Reply-To: <1463128649-20832-3-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 13, 2016 at 09:37:27AM +0100, Paul Durrant wrote:
> My recent patch to include/xen/interface/io/netif.h defines a new shared
> ring (in addition to the rx and tx rings) for passing control messages
> from a VM frontend driver to a backend driver.
> 
> A previous patch added the necessary boilerplate for mapping the control
> ring from the frontend, should it be created. This patch adds
> implementations for each of the defined protocol messages.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>
