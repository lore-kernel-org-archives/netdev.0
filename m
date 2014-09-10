From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH ipvs v2] ipvs: Add simple weighted failover scheduler
Date: Thu, 11 Sep 2014 08:56:14 +0900
Message-ID: <20140910235614.GC29858@verge.net.au>
References: <20140909132015.GA21984@kmathis.internal.monetra.com>
 <alpine.LFD.2.11.1409092247220.4943@ja.home.ssi.bg>
 <20140910002108.GG16682@verge.net.au>
 <20140910061708.GD10233@verge.net.au>
 <CAPvRj6herHa82QA9iszdT1+AMu05UJML427W4wct14NZ=suYZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>
To: Kenny Mathis <kmathis@chokepoint.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:50328 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752387AbaIJX4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 19:56:18 -0400
Content-Disposition: inline
In-Reply-To: <CAPvRj6herHa82QA9iszdT1+AMu05UJML427W4wct14NZ=suYZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2014 at 09:18:24AM -0400, Kenny Mathis wrote:
> From what I can tell, ipvsadm doesn't need any specific code updates. The
> only place the schedulers are actually listed is in the man page and the
> SCHEDULERS file, so I could submit a change to ensure it's listed. When I
> tested with keepalived, the failover (fo) module showed up properly under
> ipvsadm as well without any modifications.

Thanks, I understand.

I think updating SCHEDULERS would be good but clearly its not urgent.
