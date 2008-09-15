From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver fixes
Date: Mon, 15 Sep 2008 15:07:46 -0700 (PDT)
Message-ID: <20080915.150746.24873255.davem@davemloft.net>
References: <20080915.132716.267218808.davem@davemloft.net>
	<20080915.141159.181213705.davem@davemloft.net>
	<20080915212459.GE3994@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54211
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752671AbYIOWHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 18:07:52 -0400
In-Reply-To: <20080915212459.GE3994@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Mon, 15 Sep 2008 17:24:59 -0400

> So, my takeaway from this is...
> 
> 1) Creating a bugzilla entry magically makes a bug fix acceptable?

It adds more credence to the bug.  Because it's usually reported
by a user.

> 2) We no longer want "this kills the driver" fixes?

I don't take that away from what I said.

Why is it so important to fix something "RIGHT NOW" that
has existed forever?  Where were these fixes during the
merge window?

> I disagree with that logic, and I seriously doubt Linus wants to turn
> away serious fixes to serious problems.

He wants the time outside of the merge window to work on fixing
regressions and exploitable problems.  This is so that the process
actually ends at some point.

> You just rejected patches that (a) fixed dead ethernet [de2104x],

And it's getting submitted now, because?!?

 (b) fixed an
> oops [WAN], and

It's WAN, it's been there forever, who cares and why now?

> (c) fixed memory corruption [ehea].

Again, it's been there for quite some time, why is it "now"
all of sudden now important to integrate this fix?
