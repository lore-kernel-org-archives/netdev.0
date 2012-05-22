From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] drop_monitor: convert to modular building
Date: Tue, 22 May 2012 15:05:19 +0200
Message-ID: <1337691919.3361.189.camel@edumazet-glaptop>
References: <1337178426-2470-1-git-send-email-nhorman@tuxdriver.com>
	 <1337285040-20848-1-git-send-email-nhorman@tuxdriver.com>
	 <20120517.160937.586334759945738635.davem@davemloft.net>
	 <20120517202152.GB19321@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48906 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784Ab2EVNFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 09:05:24 -0400
Received: by bkcji2 with SMTP id ji2so4945994bkc.19
        for <netdev@vger.kernel.org>; Tue, 22 May 2012 06:05:23 -0700 (PDT)
In-Reply-To: <20120517202152.GB19321@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 16:21 -0400, Neil Horman wrote:
> On Thu, May 17, 2012 at 04:09:37PM -0400, David Miller wrote:

> > 
> > Applied, althrough it didn't apply cleanly to net-next.
> > 
> 
> Apologies Dave, should have told you that I was carrying Joe P.'s cleanup patch
> in my net-next tree as well:
> http://marc.info/?l=linux-netdev&m=133727344816140&w=2
> 
> Since you noted that you had applied it, I applied it myself here.
> Neil
> 

Any plan to autoload drop_monitor module from dropwatch,
or issuing some advice ?

# dropwatch -l kas
Unable to find NET_DM family, dropwatch can't work
Cleanuing up on socket creation error

Thanks
