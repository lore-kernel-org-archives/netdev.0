From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] connector: add userspace example code into Documentation/connector/
Date: Fri, 25 Aug 2006 12:15:03 +0400
Message-ID: <20060825081502.GA17120@2ka.mipt.ru>
References: <44EE9F53.2090303@trash.net> <20060825070527.GB1816@2ka.mipt.ru> <20060825071102.GD1816@2ka.mipt.ru> <20060825.005233.28788815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:19391 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932114AbWHYIP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 04:15:26 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060825.005233.28788815.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 25, 2006 at 12:52:33AM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Fri, 25 Aug 2006 11:11:02 +0400
> 
> > Hello.
> > 
> > I was asked several times to include userspace example code into
> > Documentation, so if there is no policy against it, consider attached patch 
> > for 2.6.18. This program works with included Documentation/connector/cn_test.c 
> > connector module.
> > Thank you.
> > 
> > Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> 
> Fair enough, applied (after killing all of the trailing whitespace).

I mailed it myself and applied to 2.6.18 git tree - "patch -p1" did not
complain for sure :)

Thank you.

-- 
	Evgeniy Polyakov
