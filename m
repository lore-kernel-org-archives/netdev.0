From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next 0/6] xfrm: policy: make policy backend const
Date: Fri, 10 Feb 2017 08:37:51 +0100
Message-ID: <20170210073751.GA30338@gauss.secunet.com>
References: <20170207140019.20269-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:47046 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751026AbdBJHiD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Feb 2017 02:38:03 -0500
Content-Disposition: inline
In-Reply-To: <20170207140019.20269-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 03:00:13PM +0100, Florian Westphal wrote:
> Hi Steffen,
> 
> This series removes all places that need to write to the afinfo policy
> backends.  This then allows us to make the structures const.

All applied to ipsec-next, thanks a lot Florian!
