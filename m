From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] NET: Clone the sk_buff->iif field properly
Date: Thu, 3 Jan 2008 23:49:12 +0100
Message-ID: <20080103224912.GC7258@ami.dom.local>
References: <20080103095829.GB2000@ff.dom.local> <200801031115.34886.paul.moore@hp.com> <20080103211312.GA7258@ami.dom.local> <200801031620.06603.paul.moore@hp.com> <20080103220608.GB7258@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.190]:59474 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbYACWpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 17:45:39 -0500
Received: by mu-out-0910.google.com with SMTP id i10so5037158mue.5
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2008 14:45:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080103220608.GB7258@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 03, 2008 at 11:06:08PM +0100, Jarek Poplawski wrote:
...
> I'm not macros fan in general: just yesterday I've cursed a bit at some
> guy (I forgot the name...), who gave all these "meaningful" names to
> macros in linux/pkt_cls.h. But, maybe after some time I'll start to
> defend them as well... Especially when I try to imagine doing the same
> without them.

...Jamal, as a matter of fact, I don't know why, just about writing this
previous message, I started to like all these names without exception!
Isn't it a miracle?

Jarek P.
