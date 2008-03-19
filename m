From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][NET] ifb: set separate lockdep classes for queue locks
Date: Wed, 19 Mar 2008 12:20:17 +0000
Message-ID: <20080319122017.GA4933@ff.dom.local>
References: <20080308084628.GA2749@ami.dom.local> <20080308085854.GB2749@ami.dom.local> <20080308101540.M65133@visp.net.lb> <20080308104322.GA3301@ami.dom.local> <20080308105250.GB3301@ami.dom.local> <20080308110611.M62976@visp.net.lb> <20080308120244.GA3378@ami.dom.local> <20080319004547.M71837@visp.net.lb> <20080319073441.GA3918@ff.dom.local> <1205926469.4440.25.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	"David S. Miller" <davem@davemloft.net>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.189]:25388 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933334AbYCSU31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 16:29:27 -0400
Received: by mu-out-0910.google.com with SMTP id i10so847881mue.5
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 13:29:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1205926469.4440.25.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 19, 2008 at 07:34:29AM -0400, jamal wrote:
...
> Thanks for logging the false-positive aspect Jarek.

I guess it's something worth to remember...

Cheers,
Jarek P.
