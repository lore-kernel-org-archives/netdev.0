From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next] xfrm: remove unused helper
Date: Fri, 30 Sep 2016 09:26:01 +0200
Message-ID: <20160930072601.GJ31137@gauss.secunet.com>
References: <1474991638-10666-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:34947 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752451AbcI3H0H (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Sep 2016 03:26:07 -0400
Content-Disposition: inline
In-Reply-To: <1474991638-10666-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 27, 2016 at 05:53:58PM +0200, Florian Westphal wrote:
> Not used anymore since 2009 (9e0d57fd6dad37,
> 'xfrm: SAD entries do not expire correctly after suspend-resume').
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied to ipsec-next, thanks!
