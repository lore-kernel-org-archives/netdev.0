From: jamal <hadi@cyberus.ca>
Subject: Re: [IPROUTE2]: update documentation on mirred and IFB
Date: Thu, 20 Jul 2006 09:44:28 -0400
Message-ID: <1153403068.5098.72.camel@jzny2>
References: <1153227400.5283.62.camel@jzny2>
	 <44BED55F.1090405@andyfurniss.entadsl.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:1471 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1030309AbWGTNoc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 09:44:32 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1G3YpP-0007oH-1J
	for netdev@vger.kernel.org; Thu, 20 Jul 2006 09:44:35 -0400
To: lists@andyfurniss.entadsl.com
In-Reply-To: <44BED55F.1090405@andyfurniss.entadsl.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-20-07 at 01:59 +0100, Andy Furniss wrote:
> jamal wrote:
> > About two more or so to complete these..
> > 
> > cheers,
> > jamal
> > 
> > 
> +tc qdisc add dev lo eth0 ?
> 

Thanks for catching that Andy. It was attempt at adding ingress to
qdisc. I will wait for Stephen to swallow the other patches and then fix
this - I have at least two more patches to send in that area. Or you can
get a little gitty and send a patch ;->
BTW, if there are areas in the docs, help etc that need clarification
let me know or fix them and send patches. Or if there are better
examples to give send patches.

cheers,
jamal

