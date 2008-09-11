From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] tg3: Avoid Send BD corruption
Date: Thu, 11 Sep 2008 16:30:20 -0700 (PDT)
Message-ID: <20080911.163020.209586511.davem@davemloft.net>
References: <1221173758.12785.32.camel@HP1>
	<20080911.160117.118147467.davem@davemloft.net>
	<1221175168.12785.40.camel@HP1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org, andy@greyhouse.net
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44308
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752490AbYIKXa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 19:30:26 -0400
In-Reply-To: <1221175168.12785.40.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 11 Sep 2008 16:19:28 -0700

> OK, we'll resubmit this for net-next then.  But I still think this one
> should qualify.  We do internal testing to find as many problems as
> possible so that real users don't see too many of them.

If driver authors can do these kinds of things to their heart's
content, and then submit lots of patches fixing all the bugs they
find, where are we able to draw the line?

That's the problem.  And right now my (and Linus's) solution is to push
back and say no unless it meets strict criteria.
