From: Ben Greear <greearb@candelatech.com>
Subject: Re: Fw: [Bugme-new] [Bug 6495] New: Vlan MTU Fragmentation
Date: Fri, 05 May 2006 21:39:14 -0700
Message-ID: <445C2872.5060208@candelatech.com>
References: <20060504235628.33041b55.akpm@osdl.org>	<445B75D2.6080702@candelatech.com> <20060505193903.249feaf8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	slavon@bigtelecom.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:48266 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932427AbWEFEjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 May 2006 00:39:22 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060505193903.249feaf8.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:

> Sorry, I should have added Badalian to Cc:.  He's using 3c905C (3c59x.c,
> allegedly maintained by myself).
> 
> (Badalian, please use emailed reply-to-all rather than the bugzilla
> interface for the remainder of this discussion, thanks).
> 

There is an ancient patch on this page:

http://www.bewley.net/linux/vlan/patches/

I have no idea if this would apply or if it has already been put into the
kernel.  I also don't have any 3com nics to test with, but there are probably
folks on the vlan mailing list that could try patches...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

