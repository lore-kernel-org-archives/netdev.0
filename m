From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Sat, 23 Jun 2007 13:44:56 -0700
Message-ID: <467D8648.2040407@candelatech.com>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com>	<467CF8AC.80103@trash.net> <467D3A48.20706@candelatech.com>	<m14pkya8fv.fsf@ebiederm.dsl.xmission.com>	<467D7E0D.7060206@candelatech.com> <m1myyq8ky6.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:51505 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245AbXFWUpH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2007 16:45:07 -0400
In-Reply-To: <m1myyq8ky6.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> So it may be that we can cover your scenario.  However it is just
> enough off of the beaten path that I'm not going to worry about it
> the first time through.  It looks like it is a very small step from
> where I am at to where you want to be.  So you may be able to cook
> up something that will satisfy your requirements relatively easily.
>   
That sounds fair to me.

I will assume that as long as you can migrate sockets with the methods you
described, it should not be that difficult to do the same with a sockopt
or similar.

I'll revisit this when your patches are in mainline.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


