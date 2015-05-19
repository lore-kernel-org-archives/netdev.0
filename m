From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH 05/13] xen-netback: refactor xenvif_rx_action
Date: Tue, 19 May 2015 16:32:11 +0100
Message-ID: <20150519153211.GD26335@zion.uk.xensource.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-6-git-send-email-joao.martins@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<david.vrabel@citrix.com>, <boris.ostrovsky@oracle.com>,
	<konrad.wilk@oracle.com>
To: Joao Martins <joao.martins@neclab.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:29818 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754122AbbESPcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 11:32:32 -0400
Content-Disposition: inline
In-Reply-To: <1431451117-70051-6-git-send-email-joao.martins@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 07:18:29PM +0200, Joao Martins wrote:
> Refactor xenvif_rx_action by dividing it into build_gops and
> submit, similar to what xenvif_tx_action looks like.
> 
> Signed-off-by: Joao Martins <joao.martins@neclab.eu>

Reviewed-by: Wei Liu <wei.liu2@citrix.com>
