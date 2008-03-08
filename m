From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Sat, 8 Mar 2008 11:56:11 +0200
Message-ID: <20080308095437.M7291@visp.net.lb>
References: <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local> <1204811995.4440.30.camel@localhost> <20080306175629.GA2876@ami.dom.local> <1204836523.4457.103.camel@localhost> <20080306214000.GC2876@ami.dom.local> <1204846839.4431.23.camel@localhost> <20080307075113.GA3912@ff.dom.local> <1204898002.4431.99.camel@localhost> <20080308084628.GA2749@ami.dom.local> <20080308085854.GB2749@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>, jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:55519 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbYCHJ4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 04:56:21 -0500
In-Reply-To: <20080308085854.GB2749@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I apply proposel patch at http://marc.info/?l=linux-
netdev&m=120481096107584&w=2

and not able to trigger lockdep warning anymore.
It is expected result?

On Sat, 8 Mar 2008 09:58:54 +0100, Jarek Poplawski wrote
> On Sat, Mar 08, 2008 at 09:46:28AM +0100, Jarek Poplawski wrote:
> ....
> > said doesn't use this patch with it's ingress (at least currently).
> 
> + said doesn't use this path with it's ingress (at least currently).
> 
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

