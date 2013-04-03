From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Suggestion] ISDN: isdnloop:  C grammar issue,  '}' miss match
 'if' and 'switch' statement.
Date: Wed, 03 Apr 2013 07:31:17 -0700
Message-ID: <1364999477.13853.21.camel@edumazet-glaptop>
References: <515C303B.1040304@asianux.com>
	 <20130403140823.GB3401@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chen Gang <gang.chen@asianux.com>, fengguang.wu@intel.com,
	isdn@linux-pingi.de,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Joe Perches <joe@perches.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:56610 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757611Ab3DCObV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 10:31:21 -0400
Received: by mail-pd0-f176.google.com with SMTP id r11so875041pdi.35
        for <netdev@vger.kernel.org>; Wed, 03 Apr 2013 07:31:20 -0700 (PDT)
In-Reply-To: <20130403140823.GB3401@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-03 at 16:08 +0200, Michal Kubecek wrote:

> As far as I can see, this rather comes from
> 
> commit 475be4d85a274d0961593db41cf85689db1d583c
> Author: Joe Perches <joe@perches.com>
> Date:   Sun Feb 19 19:52:38 2012 -0800
> 
>     isdn: whitespace coding style cleanup

And what is the problem exactly ?

# make drivers/isdn/isdnloop/isdnloop.o
  ...
  CC [M]  drivers/isdn/isdnloop/isdnloop.o

No error here.
