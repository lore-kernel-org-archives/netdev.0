From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH REPOST 1/2] NET: Accurate packet scheduling
	for	ATM/ADSL (kernel)
Date: Thu, 19 Oct 2006 20:49:14 -0400
Message-ID: <1161305354.5034.50.camel@jzny2>
References: <1161041677.6247.1.camel@ras.pc.brisbane.lube>
	 <1161090444.5555.13.camel@jzny2>  <45378DE3.8080700@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Russell Stuart <russell-tcatm@stuart.id.au>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:39832 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751635AbWJTAtT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 20:49:19 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GaiZh-00082f-Ce
	for netdev@vger.kernel.org; Thu, 19 Oct 2006 20:49:25 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <45378DE3.8080700@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-19-10 at 16:38 +0200, Patrick McHardy wrote:
> jamal wrote:
> > ACKed-by: Jamal Hadi Salim
> > 
> > When Patrick has his patch ready after this goes in we can revisit.
> 
> NACK.
> 
> I still think this patch shouldn't go in. There's no point in doing the
> same thing twice, and I haven't heard a compelling argument why it has
> to be done in a way that only helps qdiscs using rtabs while ignoring
> statistics and estimators (I even provided a patch to show how to do
> it without these limitations).

The poor guy has been persistent and has some good ideas and we need to
encourage him to stick around.  Why dont you help him get the patch in
the shape you think is reasonable? I know you are busy elsewhere and
your patch has been a while since you last promised. I will try to help
as well. 

> Besides that:

I will let Russell respond to the critique (As well as the concept of
stats and estimator); Russell please try to be brief and to the point (I
still have to learn that lesson myself ;->).

cheers,
jamal

