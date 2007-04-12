From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] allow VLAN interface on top of bridge interface
Date: Thu, 12 Apr 2007 14:59:45 -0700 (PDT)
Message-ID: <20070412.145945.124891857.davem@davemloft.net>
References: <20070412143456.2e4019f0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.borsboom@erasmusmc.nl,
	greearb@candelatech.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48703
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030788AbXDLV7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 17:59:44 -0400
In-Reply-To: <20070412143456.2e4019f0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is the second time this patch has been forwarded to netdev
in the past hour.

And I'll say the same thing I said to the first person who did it this
way.  Because you just blindly forwarded this here, and did not tell
the orignal poster why, and furthermore took linux-kernel off the CC
list, we now have two problems:

1) The poster hasn't learned where the correct location is
   to send the report and why that is the correct place.
   They just see their report getting forwarded around.

2) Since linux-kernel got dropped, people will reply to both
   instances of the original posting, so people watching the
   thread one on side will miss the postings made on the
   other.

I'd appreciate it if the poster were explicitly informed of where
they should send their report as well as retaining linux-kernel
on the CC: list if forwarding to netdev as well so we can avoid
both of these problems.

Thanks.
