From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] net: Add etun driver
Date: Fri, 06 Apr 2007 14:38:50 -0700
Message-ID: <4616BDEA.1080502@candelatech.com>
References: <m1abxl5j4s.fsf@ebiederm.dsl.xmission.com> <20070406133420.2f098bc6@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Dmitry Mishin <dim@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:57919 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933058AbXDFVjd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2007 17:39:33 -0400
In-Reply-To: <20070406133420.2f098bc6@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Why not implement a true virtual network rather than simple
> tunnel pairs?
>   
What would a true virtual network do?  You mean with routers and such?

I use my redirect device (basically same as etun) to join virtual 
routers together,
but all of the virtual routing (and bridging, etc) logic is already in 
the kernel
and just has to be configured properly....

Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


