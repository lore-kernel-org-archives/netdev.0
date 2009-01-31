From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 01/11] sfc: SFT9001: Enable robust link training
Date: Sat, 31 Jan 2009 00:04:15 +0000
Message-ID: <1233360255.2799.17.camel@hashbaz.i.decadent.org.uk>
References: <20090129.170811.135213740.davem@davemloft.net>
	 <20090130034810.GC15266@solarflare.com>
	 <20090130.140904.37637243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:3450 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754153AbZA3X6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 18:58:40 -0500
In-Reply-To: <20090130.140904.37637243.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-01-30 at 14:09 -0800, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 30 Jan 2009 03:48:10 +0000
> 
> > From: Steve Hodgson <shodgson@solarflare.com>
> > 
> > Enable a firmware option that appears to be necessary for reliable
> > operation.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> I applied all of these patches but:
> 
> 1) When you get changes written by other people, such as
>    Steve Hodgson here and in the next few patches, you need
>    to get Signed-off-by lines from them too.

I have been attributing changes to my colleagues for some time and never
heard this.  In any case the copyright lies with my employer and I am
authorised to release these changes; isn't that what my initial sign-
off means?

> 2) Outside of the merge window I do not want to see totally
>    irrelevant stuff like PHY loopback fixes.
> 
>    Those kinds of fixes are totally inappropriate at this time.

Are you saying that a spurious self-test failure is not a serious bug?

> You have been warned :-)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


