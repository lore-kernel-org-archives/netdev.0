From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/9] [RESEND] s390: lcs / ctcm / claw / netiucv patches
 for 2.6.29
Date: Tue, 24 Mar 2009 15:29:48 -0700 (PDT)
Message-ID: <20090324.152948.107572168.davem@davemloft.net>
References: <20090324132742.300929000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: ursula.braun@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53095
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755655AbZCXWaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 18:30:01 -0400
In-Reply-To: <20090324132742.300929000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>
Date: Tue, 24 Mar 2009 14:27:42 +0100

> sorry for the resend; I detected compiler and checkpatch warnings in
> patch 8, which are now removed.
> 
> Here are a couple of drivers/s390/net-patches for 2.6.29 :

We are past 2.6.29 and are developing 2.6.30

> 1/9: lcs:     exploit <linux/kthread.h>          - Klaus-Dieter Wacker
> 2/9: lcs:     hard_start_xmit return codes       - Klaus-Dieter Wacker
> 3/9: netiucv: hard_start_xmit return codes       - Ursula Braun
> 4/9: claw:    hard_start_xmit return codes       - Ursula Braun
> 5/9: ctcm:    hard_start_xmit return codes       - Ursula Braun
> 6/9: ctcm:    avoid wraparound in length of incoming data - Roel Kluin
> 7/9: ctcm:    minor findings from code analysis tool      - Joel Fowler
> 8/9: claw:    convert printk messages to kmsg api    - Andy Richter
> 9/9: claw:    minor findings from code analysis tool - Andy Richter

As I mentioned net-next-2.6 already has the kmsg patch #8, I
added the rest.

Thanks.
