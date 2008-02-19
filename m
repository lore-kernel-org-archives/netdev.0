From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Tue, 19 Feb 2008 10:36:51 +0000
Message-ID: <20080219103651.GB3898@ff.dom.local>
References: <47B17BCD.2070903@katalix.com> <20080214130016.GA2583@ff.dom.local> <47BA0214.40703@katalix.com> <20080218.202934.79548477.davem@davemloft.net> <47BA9B50.8040404@katalix.com> <20080219103047.GA3898@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.189]:47105 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753394AbYBSKgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 05:36:02 -0500
Received: by fk-out-0910.google.com with SMTP id z23so2319542fkz.5
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 02:35:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080219103047.GA3898@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 19, 2008 at 10:30:47AM +0000, Jarek Poplawski wrote:
...
> IMHO, just like I wrote earlier, the main problem is in ppp_generic(),

...or maybe ppp_generic.c? Whatever...

Jarek P.
