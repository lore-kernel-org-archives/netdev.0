From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v2 net-next 0/2] rocker: unused parameter and const
 cleanups
Date: Tue, 19 May 2015 09:17:51 +0900
Message-ID: <20150519001749.GA27631@vergenet.net>
References: <1431574976-18214-1-git-send-email-simon.horman@netronome.com>
 <20150518.154722.1576136891396287892.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, sfeldma@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34441 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbbESASC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 20:18:02 -0400
Received: by pabru16 with SMTP id ru16so172847755pab.1
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 17:18:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150518.154722.1576136891396287892.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2015 at 03:47:22PM -0400, David Miller wrote:
> From: Simon Horman <simon.horman@netronome.com>
> Date: Thu, 14 May 2015 12:42:54 +0900
> 
> > This series provides some minor though verbose cleanup of rocker.
> > 
> > The second patch depends on the first though it could be rebased.
> > 
> > * Changes v1 -> v2
> >   - Found quite a few more variables and parameters to make const
> 
> As stated, you wanted me to hold off on this series for now.
> 
> Please resubmit when the problems you've run into have been
> resolved, thanks!

Thanks Dave,

will do.

I am working through those problems. I believe they are unrelated
to this patch set. But I also believe its best to fix them before
proceeding with this patch set.
