From: David Miller <davem@davemloft.net>
Subject: Re: IPVS Sysctl Variables
Date: Fri, 30 Jun 2006 14:20:45 -0700 (PDT)
Message-ID: <20060630.142045.106433722.davem@davemloft.net>
References: <20060630061940.GA31956@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:54216
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932994AbWF3VUr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 17:20:47 -0400
To: horms@verge.net.au
In-Reply-To: <20060630061940.GA31956@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Horms <horms@verge.net.au>
Date: Fri, 30 Jun 2006 15:19:41 +0900

> there are quite a number of entries under /proc/sys/net/ipv4/vs,
> I swear that they were documented in Documentation/networking/
> at some stage, but perhaps I am dreaming.
> 
> In any case, if I clean up the information at the following URL (which a
> probably complete list of what the options are and what they do, you don't
> have to check if you don't want to), is it appropriate for inclusion in
> Documentation/networking/, and if so, should it be in ip-sysctl.txt, or
> elsewhere?
> 
> http://www.linuxvirtualserver.org/docs/sysctl.html

Good question, maybe ip-sysctl.txt is getting a bit crowded.
I therefore wouldn't mind you putting this into networking/ipvs-sysctl.txt

Thanks Simon.
