From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH 1/1] net/fec: do not pass NULL dev to DMA API
Date: Sat, 2 Apr 2011 16:31:32 +0800
Message-ID: <20110402083131.GB26533@S2100-06.ap.freescale.net>
References: <1301726391-7431-1-git-send-email-b29396@freescale.com>
 <20110402.005714.258110130.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <b29396@freescale.com>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:49825
	"EHLO VA3EHSOBE008.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753988Ab1DBI35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2011 04:29:57 -0400
Content-Disposition: inline
In-Reply-To: <20110402.005714.258110130.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Sat, Apr 02, 2011 at 12:57:14AM -0700, David Miller wrote:
> 
> First, your patches never make it to the mailing list because the list
> server rejects your postings, due to the fact that there are syntax
> errors in your email headers:
> 
> Illegal-Object:	Syntax error in From: address found on vger.kernel.org:
> 	From:	Aisheng.Dong<b29396@freescale.com>
> 				    ^-missing end of mailbox
> 
Yes, we were aware of that the mail did not get distributed by vger
list.  But we do not know why.  Thanks for telling.

I'm not quite sure about the "^" indication.  Is it telling that there
should be a space between display name and mail address?

-- 
Regards,
Shawn

