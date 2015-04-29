From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: iproute2 regression -- ss -u returns an empty list
Date: Wed, 29 Apr 2015 12:46:27 +0300
Message-ID: <20150429094627.GA676@angus-think.wlc.globallogic.com>
References: <553EE0D9.3050601@ionic.de>
 <20150428112108.GA22108@angus-think.wlc.globallogic.com>
 <553F87B7.7090602@ionic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: Mihai Moldovan <ionic@ionic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:34267 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966117AbbD2Jqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 05:46:52 -0400
Received: by laat2 with SMTP id t2so15806153laa.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 02:46:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <553F87B7.7090602@ionic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2015 at 03:14:31PM +0200, Mihai Moldovan wrote:
> Hi Vadim,
> 
> 
> On 28.04.2015 01:21 PM, Vadim Kochan wrote:
> > Seems I have a fixed version, I tested it localy with different
> > option combinations, and now there should be no issues when specifying
> > different families.
> 
> Thanks for the quick work! I'm happy to test.
> 
> 
> > Would you be able to test it ? How I can provide a fixed version to you -
> > by patch or I can push to my github and give you a link ?
> 
> I don't mind, any way is fine. I can work either way.
> 
> 
> 
> Mihai
> 
> 

Hi Stephen,

I just saw that Linux 4.0.1 was released so I assume that you will
prepare the v4.0.1 tag for iproute2 too, but would you please wait until
this bug will be fixed ? I already have a working patch (from my point
of view it works better than before), so I'd like to wait when Mihai
will test the patch which I have sent directly to him.

Thanks,
Vadim
