From: Jeff Garzik <jeff@garzik.org>
Subject: Re: d80211 merge plans
Date: Thu, 10 Aug 2006 02:11:03 -0400
Message-ID: <44DACDF7.2000101@garzik.org>
References: <200608090703.45651.mb@bu3sch.de> <20060808.224838.41637123.davem@davemloft.net> <44DA40E7.3040806@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mb@bu3sch.de, jbenc@suse.cz,
	linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:2257 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1161063AbWHJGLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 02:11:16 -0400
To: Mohamed Abbas <mabbas@linux.intel.com>
In-Reply-To: <44DA40E7.3040806@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mohamed Abbas wrote:
> David Miller wrote:
>> I think this is a non-started until the SMP problems are worked
>> out.  Is it still SMP challenged?

> I been using d80211 stack for about a month I have not encounter any SMP 
> issues. We are currently involving validation engineers to do more 
> stress tests and will see if any SMP issues come up.


Well, tests are interesting, but I would rather see a real _analysis_ of 
the locking.

Locking is provable, you know...

	Jeff


