From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: merge window is CLOSED
Date: Tue, 2 Jul 2013 20:21:26 +0200
Message-ID: <20130702182126.GA1648@minipsycho.orion>
References: <20130701.131446.1966898867588132714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:37578 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753131Ab3GBSVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 14:21:31 -0400
Received: by mail-ee0-f54.google.com with SMTP id t10so2910632eei.27
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 11:21:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130701.131446.1966898867588132714.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 01, 2013 at 10:14:46PM CEST, davem@davemloft.net wrote:
>
>With the 3.10 release, the merge window is closed.
>
>If it's not a bug fix, and it isn't in patchwork right now, I
>don't want to see it until net-next is openned again.

Dave, would you please take http://patchwork.ozlabs.org/patch/256304/
as bug fix since the original nlmon behaviour is not correct?

Thanks.

>
>Thanks.
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
