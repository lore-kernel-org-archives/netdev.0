From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Re: IMQ bug: kernel reboot immediately
Date: Thu, 23 Apr 2009 12:46:49 +0000
Message-ID: <20090423124649.GA7377@ff.dom.local>
References: <49F040E8.80402@trash.net> <200904232028599062095@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: "Y. D." <duyuyang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:18044 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752780AbZDWMrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 08:47:01 -0400
Content-Disposition: inline
In-Reply-To: <200904232028599062095@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2009 at 08:29:06PM +0800, Y. D. wrote:
> 
> >I'd rather suggest to get rid of it and use ifb, AFAIK there hasn't
> >been a single version in all those years that didn't cause this kind
> >of problems.
> Thanks for your information. 
> 
> I just want to shape ingress traffic with my own qdisc, shoule it be IMQ or IFB.
> I am wondering where I can get a little detailed usage guide about IFB. ANY clue?
> 

There is doc/actions/ifb-README in iproute2 sources. And google
as usual...

Jarek P.
