From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] connector: add userspace example code into Documentation/connector/
Date: Fri, 25 Aug 2006 12:27:00 +0400
Message-ID: <20060825082700.GA28950@2ka.mipt.ru>
References: <20060825071102.GD1816@2ka.mipt.ru> <20060825.005233.28788815.davem@davemloft.net> <20060825081502.GA17120@2ka.mipt.ru> <20060825.011727.35466920.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:18355 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751320AbWHYI1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 04:27:09 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060825.011727.35466920.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 25, 2006 at 01:17:27AM -0700, David Miller (davem@davemloft.net) wrote:
> > I mailed it myself and applied to 2.6.18 git tree - "patch -p1" did
> > not complain for sure :)
> 
> GIT always complains very loudly about any trailing whitespace on any
> lines, patch is too dumb to do that.
> 
> You do not need to use GIT trees to check this, just run:
> 
> git apply --check --whitespace=error-all $PATCH
> 
> and it will let you know.

Hmm, how many interesting things git contain...
I will definitely use this feature, thanks David.

-- 
	Evgeniy Polyakov
