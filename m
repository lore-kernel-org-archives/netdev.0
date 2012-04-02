From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 21/51] ipvs: Stop using NLA_PUT*().
Date: Mon, 2 Apr 2012 15:22:45 +0900
Message-ID: <20120402062240.GA27344@verge.net.au>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
 <1333335521-1348-22-git-send-email-davem@davemloft.net>
 <20120402050142.GA20454@verge.net.au>
 <20120402.010302.1302861329843358875.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:40902 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947Ab2DBGWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 02:22:53 -0400
Content-Disposition: inline
In-Reply-To: <20120402.010302.1302861329843358875.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 02, 2012 at 01:03:02AM -0400, David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Mon, 2 Apr 2012 14:01:49 +0900
> 
> > do you want me to take this patch or do you plan to take it directly?
> 
> I plan to take the whole series, otherwise I can't put the
> commit in at the end that deletes these interfaces.

Thanks, got it.
