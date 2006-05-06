From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: [Bugme-new] [Bug 6495] New: Vlan MTU Fragmentation
Date: Fri, 5 May 2006 23:17:59 -0700
Message-ID: <20060505231759.5ad77e95.akpm@osdl.org>
References: <20060504235628.33041b55.akpm@osdl.org>
	<445B75D2.6080702@candelatech.com>
	<20060505193903.249feaf8.akpm@osdl.org>
	<445C2872.5060208@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	slavon@bigtelecom.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:57526 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750940AbWEFGSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 May 2006 02:18:15 -0400
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <445C2872.5060208@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 05 May 2006 21:39:14 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Andrew Morton wrote:
> 
> > Sorry, I should have added Badalian to Cc:.  He's using 3c905C (3c59x.c,
> > allegedly maintained by myself).
> > 
> > (Badalian, please use emailed reply-to-all rather than the bugzilla
> > interface for the remainder of this discussion, thanks).
> > 
> 
> There is an ancient patch on this page:
> 
> http://www.bewley.net/linux/vlan/patches/
> 
> I have no idea if this would apply or if it has already been put into the
> kernel.  I also don't have any 3com nics to test with, but there are probably
> folks on the vlan mailing list that could try patches...
> 

Yeah, that was merged ages ago.

I guess I can type simple commands and add printks.  Do you have time to
take a look at the driver and suggest what I should be looking for?
