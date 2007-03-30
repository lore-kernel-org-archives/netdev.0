From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: [Bonding-devel] quick help with bonding?
Date: Thu, 29 Mar 2007 19:19:08 -0600
Message-ID: <460C658C.7090803@nortel.com>
References: <460BE5F0.7070606@nortel.com> <20070329181617.GA25770@gospo.rdu.redhat.com> <460C38EF.1080509@nortel.com> <4074.1175207458@death> <460C4EFE.6030505@nortel.com> <20070330003630.GA18319@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:34558 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934366AbXC3BTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 21:19:22 -0400
In-Reply-To: <20070330003630.GA18319@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek wrote:

> If you are looking for a decent source for patches you could consider
> downloading the latest source-rpm from RHEL4/CentOS4.  The bonding
> driver in those releases have been updated to much later code and I can
> tell you from personal experience they work pretty well.  You may need
> to do some backporting to get the latest arp-monitoring features, but
> let me know if you need a hand with that, I might have some laying
> around. ;)

I'm just about to load a kernel with a backport of bonding from 2.6.14. 
  I'll try it out and if it doesn't help I'll try the RHEL4 one.

> Does eth6 use the same hardware/driver as eth4/5?  (Sorry if I missed
> that in the thread, but didn't see if you indicated that it did.)

No, eth6 is an AMD-8111.

Chris
