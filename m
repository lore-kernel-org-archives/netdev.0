From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH] qla3xxx: add missing __iomem annotation
Date: Wed, 23 Feb 2011 13:47:58 -0800
Message-ID: <20110223214757.GA5763@linux-ox1b.qlogic.org>
References: <20110223095427.38a67186@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:36556 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753942Ab1BWWcF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 17:32:05 -0500
Content-Disposition: inline
In-Reply-To: <20110223095427.38a67186@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 23, 2011 at 09:54:27AM -0800, Stephen Hemminger wrote:
> Add necessary annotations about pointer to io memory space
> that is checked by sparse.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>

Thanks Stephen.  Looks good.

Acked-by: Ron Mercer <ron.mercer@qlogic.com>
